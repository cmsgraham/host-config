# Rollback: point WSL back at the untouched original on F:. Run from an ADMIN PowerShell.
$ErrorActionPreference = 'Stop'
$key = Get-ChildItem HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss | Where-Object { (Get-ItemProperty $_.PSPath).DistributionName -eq 'Ubuntu' }
$keepalive = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\wsl-keepalive.vbs"
Get-CimInstance Win32_Process -Filter "Name='wscript.exe'" | Where-Object { $_.CommandLine -like '*wsl-keepalive.vbs*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
Get-Process 'Docker Desktop','com.docker.backend','com.docker.build' -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process wsl -ErrorAction SilentlyContinue | Stop-Process -Force
wsl.exe --shutdown; Start-Sleep -Seconds 8
if ((wsl.exe -l --running -q 2>$null | Out-String).Replace("`0",'').Trim()) { throw 'WSL is still running; retry.' }
Set-ItemProperty $key.PSPath -Name BasePath -Value 'F:\wsl\Ubuntu'
"BasePath now: $((Get-ItemProperty $key.PSPath).BasePath)"
wsl.exe -d Ubuntu -- bash -lc 'df -h / | tail -1'
if (Test-Path $keepalive) { Start-Process wscript.exe -ArgumentList '//B', "`"$keepalive`"" }
