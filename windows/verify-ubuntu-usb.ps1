# Read-only: hash the first <iso length> bytes of USB disk 4 and compare with the Ubuntu ISO's official sha256.
$ErrorActionPreference = 'Stop'
$log = 'C:\Users\crist\verify-ubuntu-usb.log'
function L($m){ "$(Get-Date -Format HH:mm:ss) $m" | Out-File -FilePath $log -Append -Encoding ascii }
try {
  $n = 4; [long]$len = (Get-Item 'C:\Users\crist\Downloads\ubuntu-24.04.5-live-server-amd64.iso').Length
  $d = Get-Disk -Number $n; if ($d.BusType -ne 'USB' -or $d.FriendlyName -notlike '*SanDisk*') { throw "disk $n is not the SanDisk stick" }
  $chk = New-Object IO.FileStream("\\.\PhysicalDrive$n", [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::ReadWrite, 4194304)
  $buf = New-Object byte[] 4194304; $sha = [Security.Cryptography.SHA256]::Create(); [long]$left = $len
  while ($left -gt 0) {
    [long]$want = [Math]::Min([long]$buf.Length, $left); [int]$want512 = [int]([Math]::Ceiling($want / 512.0) * 512)
    $r = $chk.Read($buf, 0, $want512); if ($r -le 0) { throw "short read" }
    [int]$take = [int][Math]::Min([long]$r, $left); [void]$sha.TransformBlock($buf, 0, $take, $null, 0); $left -= $take
  }
  [void]$sha.TransformFinalBlock((New-Object byte[] 0), 0, 0); $chk.Close()
  $h = ([BitConverter]::ToString($sha.Hash) -replace '-','').ToLower(); L "readback sha256 $h"
  if ($h -eq '97f3d7ffb032c3eb3b23d2c8be9cc76e60c2c1f2c0146ba5ba9fe01cafae0fd8') { L "VERIFIED OK" } else { L "VERIFY FAILED" }
} catch { L "ERROR: $($_.Exception.Message)" }
