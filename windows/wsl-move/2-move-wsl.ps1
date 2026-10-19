# Step 2: COPY Ubuntu's disk from F: to G: and point WSL at the copy. F: is left untouched as the backup.
# Run from an ADMIN PowerShell:  powershell -ExecutionPolicy Bypass -File C:\Users\crist\wsl-move\2-move-wsl.ps1
$ErrorActionPreference = 'Stop'
$src = 'F:\wsl\Ubuntu'; $dst = 'G:\wsl\Ubuntu'; $log = 'C:\Users\crist\wsl-move\move.log'
$key = Get-ChildItem HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss | Where-Object { (Get-ItemProperty $_.PSPath).DistributionName -eq 'Ubuntu' }
if (@($key).Count -ne 1) { throw 'Could not find exactly one WSL distro named Ubuntu.' }
$base = (Get-ItemProperty $key.PSPath).BasePath
"Ubuntu BasePath now: $base" | Tee-Object -FilePath $log
if ($base -notlike '*F:\wsl\Ubuntu') { throw "BasePath is not F:\wsl\Ubuntu - tell Claude." }
if (-not (Test-Path "$src\ext4.vhdx")) { throw "$src\ext4.vhdx not found." }
$vol = Get-Volume -DriveLetter G
if ($vol.FileSystem -ne 'NTFS') { throw 'G: is not NTFS.' }
$need = (Get-Item "$src\ext4.vhdx").Length
if ($vol.SizeRemaining -lt $need + 20GB) { throw "G: has $([int]($vol.SizeRemaining/1GB)) GB free, need $([int]($need/1GB)+20)." }
# BasePath is still F: (asserted above), so any ext4.vhdx already on G: is a stale partial copy
# from an earlier attempt (the first run stalled at 97% in robocopy /J mode). Remove it.
if (Test-Path "$dst\ext4.vhdx") {
    if (Get-Process Robocopy -ErrorAction SilentlyContinue) { throw 'A robocopy is still running - press Ctrl+C in its window first.' }
    "Removing stale partial copy $dst\ext4.vhdx" | Tee-Object -FilePath $log -Append
    Remove-Item "$dst\ext4.vhdx" -Force
}
# Keep the machine awake while copying (the first attempt stalled when the session locked/dozed).
Add-Type -Namespace WslMove -Name Power -MemberDefinition '[DllImport("kernel32.dll")] public static extern uint SetThreadExecutionState(uint esFlags);'
[WslMove.Power]::SetThreadExecutionState([uint32]0x80000003) | Out-Null   # CONTINUOUS | SYSTEM_REQUIRED | DISPLAY_REQUIRED

# --- Stop everything that re-attaches to the VM, then shut it down -------------------------
# wsl-keepalive.vbs (Startup folder) loops `wsl -d Ubuntu ... sleep infinity` and re-boots Ubuntu
# ~30 s after any `wsl --shutdown`, which is why the first attempt reported "still running".
$keepalive = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\wsl-keepalive.vbs"
Get-CimInstance Win32_Process -Filter "Name='wscript.exe'" |
    Where-Object { $_.CommandLine -like '*wsl-keepalive.vbs*' } |
    ForEach-Object { "Stopping keepalive loop (pid $($_.ProcessId))"; Stop-Process -Id $_.ProcessId -Force }
# Docker Desktop's WSL integration also holds the distro open; quit it for the duration of the copy.
$dockerWasRunning = [bool](Get-Process 'Docker Desktop' -ErrorAction SilentlyContinue)
if ($dockerWasRunning) {
    'Stopping Docker Desktop...'
    Get-Process 'Docker Desktop','com.docker.backend','com.docker.build','com.docker.dev-envs' -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep -Seconds 5
}
Get-Process wsl -ErrorAction SilentlyContinue | Stop-Process -Force

'Shutting WSL down...'
wsl.exe --shutdown
$down = $false
foreach ($i in 1..6) {
    Start-Sleep -Seconds 5
    $running = (wsl.exe -l --running -q 2>$null | Out-String).Replace("`0",'').Trim()
    if (-not $running) { $down = $true; break }
    "Still running ($running); killing stray wsl.exe and retrying ($i/6)..."
    Get-Process wsl -ErrorAction SilentlyContinue | Stop-Process -Force
    wsl.exe --shutdown
}
if (-not $down) {
    $holders = Get-CimInstance Win32_Process | Where-Object { $_.Name -match '^wsl' -or $_.CommandLine -match 'wsl' } |
        ForEach-Object { "  $($_.ProcessId) $($_.Name) <- parent $($_.ParentProcessId): $($_.CommandLine)" }
    throw "WSL is still running after 30 s. Processes attached to it:`n$($holders -join "`n")`nClose them (VS Code Remote-WSL windows, terminals) and retry."
}

New-Item -ItemType Directory -Force $dst | Out-Null
"Copying $([int]($need/1GB)) GB ($(Get-Date -f T))..." | Tee-Object -FilePath $log -Append
# Buffered copy (no /J): the unbuffered mode hung at 97% on the first attempt.
robocopy $src $dst ext4.vhdx /ETA /R:1 /W:5
if ($LASTEXITCODE -ge 8 -or $LASTEXITCODE -lt 0) { throw "robocopy failed with code $LASTEXITCODE; WSL still points at F: (nothing changed)." }
if ((Get-Item "$dst\ext4.vhdx").Length -ne $need) { throw 'Copied size differs; WSL still points at F:.' }
"Copy done ($(Get-Date -f T)). Verifying SHA-256 of both images (several minutes each)..." | Tee-Object -FilePath $log -Append
$hSrc = (Get-FileHash "$src\ext4.vhdx" -Algorithm SHA256).Hash
$hDst = (Get-FileHash "$dst\ext4.vhdx" -Algorithm SHA256).Hash
"  F: $hSrc`n  G: $hDst" | Tee-Object -FilePath $log -Append
if ($hSrc -ne $hDst) { throw 'Hash mismatch: the copy on G: is NOT identical. WSL still points at F:. Tell Claude.' }
"Hashes match ($(Get-Date -f T)). Pointing WSL at G:." | Tee-Object -FilePath $log -Append

Set-ItemProperty $key.PSPath -Name BasePath -Value $dst
"BasePath now: $((Get-ItemProperty $key.PSPath).BasePath)" | Tee-Object -FilePath $log -Append
'Starting Ubuntu from G: ...'
wsl.exe -d Ubuntu -- bash -lc 'df -h / | tail -1; systemctl is-active ollama ollama-gateway'
# Restore the keepalive loop (and Docker Desktop) now that the distro lives on G:.
if (Test-Path $keepalive) { Start-Process wscript.exe -ArgumentList '//B', "`"$keepalive`"" ; 'Keepalive loop restarted.' }
if ($dockerWasRunning) { Start-Process 'C:\Program Files\Docker\Docker\Docker Desktop.exe'; 'Docker Desktop restarted.' }
"`nIf Ubuntu started: open VS Code again and tell Claude 'moved'."
"ROLLBACK (only if something is wrong): run 3-rollback.ps1 - it points WSL back at F:."
