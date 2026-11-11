# Windows-side configuration snapshot for host-config (2026-11-11, disaster-recovery prep).
# Called by host-config/sync.sh (hourly, via git-backup.service) through powershell.exe; no admin needed.
# Writes plain-text / XML files into the folder given as -Out. Never copies secrets: task XML and the rest are
# configuration only (the S4U tasks store no password). Anything that needs admin to read is skipped, not failed.
param([Parameter(Mandatory = $true)][string]$Out)
$ErrorActionPreference = 'Continue'
New-Item -ItemType Directory -Force -Path $Out, "$Out\tasks" | Out-Null

# 1. Our scheduled tasks (anything not under \Microsoft\ and not a vendor updater), as importable XML
$skip = 'Adobe|OneDrive|NvDriverUpdate|NVIDIA App|GoogleUserPEH|SoftLanding|PowerToys'
Get-ScheduledTask | Where-Object { $_.TaskPath -notlike '\Microsoft\*' -and $_.TaskName -notmatch $skip -and $_.TaskPath -notmatch $skip } |
  ForEach-Object {
    $n = ($_.TaskName -replace '[\\/:*?"<>|]', '_')
    try { Export-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath | Set-Content -Encoding UTF8 "$Out\tasks\$n.xml" } catch {}
  }
Get-ScheduledTask | Where-Object { $_.TaskPath -notlike '\Microsoft\*' } |
  Select-Object TaskPath, TaskName, State | Sort-Object TaskName | Format-Table -AutoSize | Out-String -Width 220 |
  Set-Content -Encoding UTF8 "$Out\tasks\_list.txt"

# 2. WSL: .wslconfig, version, distro registration (vhdx location)
Copy-Item "$env:USERPROFILE\.wslconfig" "$Out\wslconfig.txt" -ErrorAction SilentlyContinue
(wsl.exe --version) -replace "`0", '' | Where-Object { $_ -ne '' } | Set-Content -Encoding UTF8 "$Out\wsl-version.txt"
Get-ChildItem 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss' -ErrorAction SilentlyContinue | ForEach-Object {
  $p = Get-ItemProperty $_.PSPath
  "{0}  BasePath={1}  Version={2}  Default={3}" -f $p.DistributionName, $p.BasePath, $p.Version, $p.DefaultUid
} | Set-Content -Encoding UTF8 "$Out\wsl-distros.txt"

# 3. Networking: LAN port forwards, our firewall rules, hosts file
netsh interface portproxy show all | Set-Content -Encoding UTF8 "$Out\portproxy.txt"
Get-NetFirewallRule -ErrorAction SilentlyContinue |
  Where-Object { $_.DisplayName -match 'IOC-|agent-ci|gateway|WSL|ollama|comfy|fxplat|8188|8189|11434|11500|8765' } |
  ForEach-Object {
    $pf = $_ | Get-NetFirewallPortFilter; $af = $_ | Get-NetFirewallAddressFilter
    [pscustomobject]@{ Name = $_.DisplayName; Dir = $_.Direction; Action = $_.Action; Enabled = $_.Enabled; Profile = $_.Profile
      Protocol = $pf.Protocol; LocalPort = ($pf.LocalPort -join ','); RemotePort = ($pf.RemotePort -join ','); Remote = ($af.RemoteAddress -join ',') }
  } | Export-Csv -NoTypeInformation -Encoding UTF8 "$Out\firewall-rules.csv"
Copy-Item "$env:windir\System32\drivers\etc\hosts" "$Out\hosts.txt" -ErrorAction SilentlyContinue

# 4. Policies we set by hand (Windows Update no-auto-install, etc.)
reg.exe export 'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' "$Out\policy-windowsupdate.reg" /y 2>$null | Out-Null

# 5. Machine facts that a reinstall must match
$os = Get-CimInstance Win32_OperatingSystem
$gpu = Get-CimInstance Win32_VideoController | Select-Object Name, DriverVersion
@(
  "OS: $($os.Caption) $($os.Version) build $($os.BuildNumber)"
  "Computer: $env:COMPUTERNAME  User: $env:USERNAME"
  ($gpu | ForEach-Object { "GPU: $($_.Name) driver $($_.DriverVersion)" })
  (Get-CimInstance Win32_BaseBoard | ForEach-Object { "Board: $($_.Manufacturer) $($_.Product)" })
  (Get-CimInstance Win32_BIOS | ForEach-Object { "BIOS: $($_.SMBIOSBIOSVersion)" })
  ''
  (Get-Volume | Where-Object DriveLetter | Sort-Object DriveLetter | Format-Table DriveLetter, FileSystemLabel, FileSystem, @{n='SizeGB';e={[math]::Round($_.Size/1GB)}}, @{n='FreeGB';e={[math]::Round($_.SizeRemaining/1GB)}} -AutoSize | Out-String)
) | Set-Content -Encoding UTF8 "$Out\machine.txt"

# 6. Installed applications (winget IDs, re-installable with `winget import`), at most once a day: it is slow
$apps = "$Out\winget-apps.json"
if (-not (Test-Path $apps) -or ((Get-Date) - (Get-Item $apps).LastWriteTime).TotalHours -gt 24) {
  winget export -o $apps --accept-source-agreements --disable-interactivity 2>$null | Out-Null
}
Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue |
  Where-Object DisplayName | Sort-Object DisplayName -Unique | ForEach-Object { "{0}`t{1}`t{2}" -f $_.DisplayName, $_.DisplayVersion, $_.Publisher } |
  Set-Content -Encoding UTF8 "$Out\installed-programs.tsv"

# 7. What lives in the Windows profile (sizes only), so the runbook knows what is NOT in any backup; daily (slow)
$pf = "$Out\profile-folders.txt"
if (-not (Test-Path $pf) -or ((Get-Date) - (Get-Item $pf).LastWriteTime).TotalHours -gt 24) {
Get-ChildItem $env:USERPROFILE -Directory -Force -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch '^(AppData|Application Data|Local Settings|NetHood|PrintHood|Recent|SendTo|Start Menu|Templates|Cookies|My Documents)$' } |
  ForEach-Object { $s = (Get-ChildItem $_.FullName -Recurse -File -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
    "{0,10:N1} GB  {1}" -f ($s / 1GB), $_.Name } | Sort-Object -Descending | Set-Content -Encoding UTF8 "$Out\profile-folders.txt"
}
"snapshot $(Get-Date -Format s)" | Set-Content "$Out\_stamp.txt"
