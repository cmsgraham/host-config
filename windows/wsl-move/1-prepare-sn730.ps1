# Step 1: show what is on the SN730, then (only after you type YES) wipe it and format it NTFS as G:.
# Run from an ADMIN PowerShell:  powershell -ExecutionPolicy Bypass -File C:\Users\crist\wsl-move\1-prepare-sn730.ps1
$ErrorActionPreference = 'Stop'
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole('Administrators')) { throw 'Run this from an ADMIN PowerShell.' }
$disk = Get-Disk | Where-Object FriendlyName -like '*SN730*'
if (@($disk).Count -ne 1) { throw "Expected exactly one SN730 disk, found $(@($disk).Count)." }
if ($disk.IsBoot -or $disk.IsSystem) { throw 'The SN730 is the boot/system disk - refusing.' }
"SN730 = disk $($disk.Number), $([int]($disk.Size/1GB)) GB, $($disk.PartitionStyle)"
"`n--- partitions on it ---"
Get-Partition -DiskNumber $disk.Number | Format-Table PartitionNumber, DriveLetter, @{n='GB';e={[math]::Round($_.Size/1GB,1)}}, Type, GptType -AutoSize | Out-String
"--- volumes on it ---"
Get-Partition -DiskNumber $disk.Number | Get-Volume -ErrorAction SilentlyContinue | Format-Table FileSystemLabel, FileSystem, @{n='SizeGB';e={[int]($_.Size/1GB)}}, @{n='UsedGB';e={[int](($_.Size-$_.SizeRemaining)/1GB)}} -AutoSize | Out-String
if (Get-Volume -DriveLetter G -ErrorAction SilentlyContinue) { throw 'Drive letter G: is already taken - tell Claude.' }
$ans = Read-Host "Type YES to ERASE disk $($disk.Number) ($($disk.FriendlyName)) and format it NTFS as G:"
if ($ans -cne 'YES') { 'Nothing changed.'; exit 1 }
Clear-Disk -Number $disk.Number -RemoveData -RemoveOEM -Confirm:$false
Initialize-Disk -Number $disk.Number -PartitionStyle GPT
New-Partition -DiskNumber $disk.Number -UseMaximumSize -DriveLetter G | Format-Volume -FileSystem NTFS -NewFileSystemLabel 'WSL' -Confirm:$false | Out-String
'Done. G: is ready. Now run 2-move-wsl.ps1.'
