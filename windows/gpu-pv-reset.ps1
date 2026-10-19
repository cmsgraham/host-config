<#
.SYNOPSIS
  Reset the WSL2 GPU paravirtualization path on the Windows host without a reboot.

.DESCRIPTION
  Under WSL2 every CUDA call crosses dxgkrnl (guest) -> vmbus -> dxgkrnl (host) ->
  the NVIDIA driver. That host-side state degrades with host uptime
  (microsoft/WSL#41701): the guest kernel logs `misc dxg ... wait_for_completion
  failed`, nvidia-smi gets slow, and on 2026-10-05 this machine froze after 4.5 h
  of it. `wsl --shutdown` alone does NOT clear it; restarting the GPU devices does.

  Sequence (the upstream-verified one):
    1. wsl --shutdown                 (the GPU cannot be restarted under a running VM)
    2. pnputil /restart-device        for every NVIDIA GPU that is present and started
    3. start the distro again         (systemd + lingering user manager bring the
                                       gateway, Ollama, dashboards and the agent-ci
                                       watchdog timer back; the watchdog restarts
                                       the pipeline loop)

  Screens attached to the restarted GPUs go black for a few seconds, like a driver
  update. VS Code Remote-WSL windows reconnect on their own.

  Runs elevated (pnputil needs it). Registered as the scheduled task
  "agent-ci GPU-PV reset" by register-gpu-pv-reset.ps1 so WSL can start it on
  demand with `schtasks /run` and without a UAC prompt.

  Dry run: create the file %USERPROFILE%\gpu-pv-reset.dryrun and every step is
  logged but nothing is touched.

.NOTES
  Log: %USERPROFILE%\gpu-pv-reset.log
#>
[CmdletBinding()]
param(
  [string]$Distro = "Ubuntu",
  [string]$GpuMatch = "NVIDIA GeForce RTX 3090",
  [int]$ShutdownWaitSeconds = 60,
  [int]$SettleSeconds = 8
)

$ErrorActionPreference = "Continue"
$log = Join-Path $env:USERPROFILE "gpu-pv-reset.log"
$dry = Test-Path (Join-Path $env:USERPROFILE "gpu-pv-reset.dryrun")

function Log([string]$m) {
  $line = "{0:yyyy-MM-dd HH:mm:ss} {1}{2}" -f (Get-Date), ($(if ($dry) { "[dry-run] " } else { "" })), $m
  Add-Content -Path $log -Value $line
  Write-Output $line
}

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")
Log "---- GPU-PV reset start (elevated=$isAdmin, distro=$Distro)"
if (-not $isAdmin -and -not $dry) { Log "ERROR not elevated: pnputil /restart-device needs administrator rights"; exit 2 }

# which GPUs: present + started NVIDIA cards (a stale 'Disconnected' instance is skipped)
$gpus = Get-PnpDevice -Class Display -ErrorAction SilentlyContinue |
  Where-Object { $_.FriendlyName -like "*$GpuMatch*" -and $_.Status -eq "OK" }
if (-not $gpus) { Log "ERROR no started GPU matching '$GpuMatch'"; exit 3 }
$gpus | ForEach-Object { Log ("GPU: {0} [{1}] {2}" -f $_.FriendlyName, $_.Status, $_.InstanceId) }

# 1. stop the VM
Log "wsl --shutdown"
if (-not $dry) {
  & wsl.exe --shutdown 2>&1 | Out-Null
  $deadline = (Get-Date).AddSeconds($ShutdownWaitSeconds)
  do {
    Start-Sleep -Seconds 2
    $running = (& wsl.exe -l -v 2>$null) -replace "`0", "" | Select-String -Pattern "Running" -Quiet
  } while ($running -and (Get-Date) -lt $deadline)
  if ($running) { Log "WARN a distro still shows Running after ${ShutdownWaitSeconds}s; continuing" }
  else { Log "VM is down" }
}

# 2. restart every GPU device (the step that clears the host-side state)
foreach ($g in $gpus) {
  Log ("pnputil /restart-device `"{0}`"" -f $g.InstanceId)
  if (-not $dry) {
    $out = & pnputil.exe /restart-device "$($g.InstanceId)" 2>&1
    Log ("  -> " + (($out | Out-String).Trim() -replace "\s+", " "))
  }
}
if (-not $dry) {
  Start-Sleep -Seconds $SettleSeconds
  $after = Get-PnpDevice -Class Display | Where-Object { $_.FriendlyName -like "*$GpuMatch*" -and $_.Status -eq "OK" }
  Log ("GPUs started after reset: {0} of {1}" -f (@($after).Count), (@($gpus).Count))
  if (@($after).Count -lt @($gpus).Count) { Log "ERROR a GPU did not come back; not starting WSL (a reboot is needed)"; exit 4 }
}

# 3. bring the distro back; systemd and the lingering user manager start everything else
Log "starting distro $Distro"
if (-not $dry) {
  $sys = & wsl.exe -d $Distro -- systemctl is-system-running --wait 2>&1
  Log ("  system manager: " + (($sys | Out-String).Trim()))
  $usr = & wsl.exe -d $Distro -- systemctl --user is-system-running --wait 2>&1
  Log ("  user manager: " + (($usr | Out-String).Trim()))
  $gw = & wsl.exe -d $Distro -- systemctl is-active ollama-gateway.service ollama.service 2>&1
  Log ("  gateway/ollama: " + ((($gw | Out-String).Trim()) -replace "\s+", " "))
  $pv = & wsl.exe -d $Distro -- bash -lc "journalctl -k -b --no-pager -q 2>/dev/null | grep -c 'misc dxg'" 2>&1
  Log ("  dxg lines in the fresh boot: " + (($pv | Out-String).Trim()))
}
Log "---- GPU-PV reset done"
exit 0
