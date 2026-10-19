# Make Windows Boot Manager the only/first boot entry and remove the orphaned Ubuntu GRUB.
# Run from an ADMIN PowerShell:  powershell -ExecutionPolicy Bypass -File C:\Users\crist\wsl-move\4-fix-boot.ps1
$ErrorActionPreference = 'Stop'
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole('Administrators')) { throw 'Run this from an ADMIN PowerShell.' }
$log = 'C:\Users\crist\wsl-move\fix-boot.log'
$fw = bcdedit /enum firmware
$fw | Out-File $log
"=== firmware boot entries (also saved to $log) ==="
$fw

# Split the listing into entries and find the ones whose description mentions ubuntu/grub.
$entries = @(); $cur = $null
foreach ($line in $fw) {
    if ($line -match '^identifier\s+(\{.+\})') { $cur = [ordered]@{ id = $Matches[1]; desc = ''; path = '' }; $entries += $cur }
    elseif ($cur -and $line -match '^description\s+(.+)$') { $cur.desc = $Matches[1].Trim() }
    elseif ($cur -and $line -match '^path\s+(.+)$') { $cur.path = $Matches[1].Trim() }
}
$linux = @($entries | Where-Object { $_.desc -match 'ubuntu|grub' -or $_.path -match '\\EFI\\ubuntu\\' })
"`n=== entries to remove ==="
if ($linux.Count -eq 0) { '(none found - only the boot order will be fixed)' } else { $linux | ForEach-Object { "$($_.id)  $($_.desc)  $($_.path)" } }
"`nPlan:"
"  1. bcdedit /set {fwbootmgr} displayorder {bootmgr} /addfirst   (Windows Boot Manager first)"
"  2. bcdedit /delete <each entry above>"
"  3. remove \EFI\ubuntu from the EFI system partition (if present)"
$ans = Read-Host "`nType YES to apply"
if ($ans -cne 'YES') { 'Nothing changed.'; exit 1 }

bcdedit /set '{fwbootmgr}' displayorder '{bootmgr}' /addfirst
foreach ($e in $linux) { bcdedit /delete $e.id }

$letter = 'S'
if (Get-PSDrive -Name $letter -ErrorAction SilentlyContinue) { throw "Drive $letter`: is in use; tell Claude." }
mountvol "$letter`:" /S
try {
    "`n=== EFI partition contents ==="
    Get-ChildItem "$letter`:\EFI" | Format-Table Name -AutoSize | Out-String
    if (Test-Path "$letter`:\EFI\ubuntu") { Remove-Item "$letter`:\EFI\ubuntu" -Recurse -Force; 'Removed \EFI\ubuntu' } else { 'No \EFI\ubuntu folder.' }
    if (-not (Test-Path "$letter`:\EFI\Microsoft\Boot\bootmgfw.efi")) { Write-Warning 'Windows bootmgfw.efi NOT found on this EFI partition - tell Claude before rebooting.' }
} finally { mountvol "$letter`:" /D }

"`n=== firmware boot entries now ==="
bcdedit /enum firmware | Tee-Object -FilePath $log -Append
"`nDone. Reboot: it should go straight to Windows."
