# Step 5: let a NORMAL (non-admin) process attach the moved disk.
# Run from an ADMIN PowerShell:  powershell -ExecutionPolicy Bypass -File C:\Users\crist\wsl-move\5-fix-acl.ps1
#
# Why: robocopy created G:\wsl\Ubuntu\ext4.vhdx as a new file owned by Administrators, and the fresh G: volume only
# gives your account "Modify" through Authenticated Users. WSL opens the VHD as the user who launched wsl.exe, and
# attaching it needs more than Modify (the F: original works because you OWN that file). That is why the distro
# booted from G: at 7:41 PM (launched from the admin window) but has failed with "Access is denied" from every
# non-admin launch since the reboot (keepalive loop, VS Code, terminals).
$ErrorActionPreference = 'Stop'
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole('Administrators')) { throw 'Run this from an ADMIN PowerShell.' }
$user = "$env:USERDOMAIN\$env:USERNAME"
$log = 'C:\Users\crist\wsl-move\fix-acl.log'
"Before:" | Tee-Object -FilePath $log
icacls 'G:\wsl\Ubuntu\ext4.vhdx' | Tee-Object -FilePath $log -Append

icacls 'G:\wsl' /setowner $user /T /C | Tee-Object -FilePath $log -Append
icacls 'G:\wsl' /grant "${user}:(OI)(CI)F" /T /C | Tee-Object -FilePath $log -Append

"After:" | Tee-Object -FilePath $log -Append
icacls 'G:\wsl\Ubuntu\ext4.vhdx' | Tee-Object -FilePath $log -Append

# Prove it from a NON-admin context: the wsl-keepalive.vbs loop (running as your normal user) retries
# `wsl -d Ubuntu` about every 30 s, so Ubuntu should appear as running on its own.
'Waiting up to 2 min for the (non-admin) keepalive loop to boot Ubuntu from G: ...'
$ok = $false
foreach ($i in 1..24) {
    Start-Sleep -Seconds 5
    $running = (wsl.exe -l --running -q 2>$null | Out-String).Replace("`0", '')
    if ($running -match 'Ubuntu') { $ok = $true; break }
}
if ($ok) {
    "Ubuntu is running from G: ($(Get-Date -f T)), started by a non-admin process." | Tee-Object -FilePath $log -Append
    wsl.exe -d Ubuntu -- bash -lc 'df -h / | tail -1; systemctl is-active ollama ollama-gateway 2>/dev/null'
    "`nDone. F:\wsl\Ubuntu\ext4.vhdx is still the untouched pre-move backup (last written 7:23 PM)."
    "Optional, later: 'wsl --manage Ubuntu --set-sparse true' so G: reclaims space like F: did."
} else {
    "Keepalive did not boot it within 2 min. Trying from this admin window:" | Tee-Object -FilePath $log -Append
    wsl.exe -d Ubuntu -- bash -lc 'df -h / | tail -1'
    "If that booted, the ACL fix did not take for the non-admin token - tell Claude (log: $log)."
}
