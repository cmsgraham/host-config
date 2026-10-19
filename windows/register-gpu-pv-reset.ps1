<#
.SYNOPSIS
  Register "agent-ci GPU-PV reset" as an on-demand, elevated scheduled task.

.DESCRIPTION
  Copies gpu-pv-reset.ps1 to %USERPROFILE% (the task must not read its script
  from \\wsl$ because step 1 shuts WSL down) and registers a task that runs it
  with highest privileges, no trigger. Any process of this user can then start
  it without a UAC prompt:

      schtasks.exe /run /tn "agent-ci GPU-PV reset"

  which is how the agent-ci watchdog (inside WSL) requests the reset once the
  gateway reports the GPU-PV link degrading and the pipeline is between tasks.

  Self-elevates (one UAC prompt) when not already elevated. Re-running updates
  the task in place.
#>
[CmdletBinding()]
param(
  [string]$TaskName = "agent-ci GPU-PV reset",
  [string]$Source = ""
)
$ErrorActionPreference = "Stop"
if (-not $Source) {
  # $PSScriptRoot is empty when the script is started by -File from a \\wsl$ path
  $Source = Split-Path -Parent $MyInvocation.MyCommand.Definition
}
if (-not $Source) { $Source = $env:USERPROFILE }
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")
if (-not $isAdmin) {
  # Copy both scripts from the non-elevated side (\\wsl$ is reachable here) and
  # elevate the LOCAL copy: an elevated process may not see \\wsl$ at all.
  foreach ($n in "gpu-pv-reset.ps1", "register-gpu-pv-reset.ps1") {
    Copy-Item -Path (Join-Path $Source $n) -Destination (Join-Path $env:USERPROFILE $n) -Force
  }
  $local = Join-Path $env:USERPROFILE "register-gpu-pv-reset.ps1"
  try {
    $p = Start-Process -FilePath "powershell.exe" -Verb RunAs -Wait -PassThru -ArgumentList @(
      "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$local`"", "-TaskName", "`"$TaskName`"",
      "-Source", "`"$env:USERPROFILE`"")
    exit $p.ExitCode
  } catch {
    Write-Output ("elevation failed or was declined: " + $_.Exception.Message)
    exit 5
  }
}

$dest = Join-Path $env:USERPROFILE "gpu-pv-reset.ps1"
$src = Join-Path $Source "gpu-pv-reset.ps1"
if ((Resolve-Path $src).Path -ne $dest) { Copy-Item -Path $src -Destination $dest -Force }

$action = New-ScheduledTaskAction -Execute "powershell.exe" `
  -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$dest`""
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
  -ExecutionTimeLimit (New-TimeSpan -Minutes 15) -MultipleInstances IgnoreNew -StartWhenAvailable:$false
Register-ScheduledTask -TaskName $TaskName -Action $action -Principal $principal -Settings $settings -Force `
  -Description "Clears the WSL2 GPU-PV host-side degradation (microsoft/WSL#41701): wsl --shutdown, pnputil /restart-device on the NVIDIA GPUs, restart the distro. Started on demand by the agent-ci watchdog." | Out-Null
$t = Get-ScheduledTask -TaskName $TaskName
Write-Output ("registered '{0}': state={1} runlevel={2} script={3}" -f $t.TaskName, $t.State, $t.Principal.RunLevel, $dest)
