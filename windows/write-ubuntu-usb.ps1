# Writes the Ubuntu Server ISO raw onto USB disk 4 (SanDisk Ultra 28.6 GB) and verifies it by reading it back.
$ErrorActionPreference = 'Stop'
$log = 'C:\Users\crist\write-ubuntu-usb.log'
function L($m){ "$(Get-Date -Format HH:mm:ss) $m" | Tee-Object -FilePath $log -Append }
try {
  $n = 4; $iso = 'C:\Users\crist\Downloads\ubuntu-24.04.5-live-server-amd64.iso'
  $d = Get-Disk -Number $n
  if ($d.BusType -ne 'USB' -or $d.FriendlyName -notlike '*SanDisk*' -or $d.Size -gt 40GB) { throw "disk $n is not the expected SanDisk USB stick ($($d.FriendlyName), $($d.BusType)) - aborting" }
  L "target: disk $n $($d.FriendlyName) $([math]::Round($d.Size/1GB,1)) GB"
  Clear-Disk -Number $n -RemoveData -RemoveOEM -Confirm:$false
  L "disk cleared"
  $src = [IO.File]::OpenRead($iso); $len = $src.Length
  $dst = New-Object IO.FileStream("\\.\PhysicalDrive$n", [IO.FileMode]::Open, [IO.FileAccess]::ReadWrite, [IO.FileShare]::ReadWrite, 4MB, [IO.FileOptions]::WriteThrough)
  $buf = New-Object byte[] (4MB); $done = 0; $next = 0
  while (($r = $src.Read($buf, 0, $buf.Length)) -gt 0) {
    if ($r % 512 -ne 0) { $pad = 512 - ($r % 512); [Array]::Clear($buf, $r, $pad); $r += $pad }
    $dst.Write($buf, 0, $r); $done += $r
    if ($done -ge $next) { L ("written {0:N0} MB of {1:N0} MB" -f ($done/1MB), ($len/1MB)); $next += 500MB }
  }
  $dst.Flush(); $dst.Close(); $src.Close()
  L "write complete; verifying"
  $chk = New-Object IO.FileStream("\\.\PhysicalDrive$n", [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::ReadWrite, 4MB)
  $sha = [Security.Cryptography.SHA256]::Create(); $left = $len
  while ($left -gt 0) { $want = [Math]::Min($buf.Length, $left); $want = [int]([Math]::Ceiling($want/512)*512); $r = $chk.Read($buf, 0, $want); $take = [int][Math]::Min($r, $left); [void]$sha.TransformBlock($buf, 0, $take, $null, 0); $left -= $take }
  [void]$sha.TransformFinalBlock((New-Object byte[] 0), 0, 0); $chk.Close()
  $h = ([BitConverter]::ToString($sha.Hash) -replace '-','').ToLower()
  L "readback sha256 $h"
  if ($h -eq '97f3d7ffb032c3eb3b23d2c8be9cc76e60c2c1f2c0146ba5ba9fe01cafae0fd8') { L "VERIFIED OK - the stick is ready" } else { L "VERIFY FAILED" }
} catch { L "ERROR: $($_.Exception.Message)" }
