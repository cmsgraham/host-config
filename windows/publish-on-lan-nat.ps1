# Publish the gateway on the LAN, on a NAT-networking WSL box.
#
# Use THIS, not publish-on-lan.ps1. That one switches WSL to mirrored
# networking, which was tried on this machine on 2026-09-06 and could not pass
# ANY Windows -> WSL traffic (see the comment in %USERPROFILE%\.wslconfig).
# The box is on networkingMode=NAT + localhostForwarding, and stays there.
#
# On NAT, `localhostForwarding` binds wslrelay to 127.0.0.1 ONLY, so the
# gateway answers on the host's own loopback and is invisible to the LAN. The
# bridge is a portproxy from the host's LAN address to the WSL VM's address.
#
# WHY IT KEEPS BREAKING: the WSL VM gets a new IP on every `wsl --shutdown`,
# and the vEthernet (WSL) adapter is recreated, which silently stops existing
# portproxy listeners from binding even when their target is still correct.
# That is the state this script found on 2026-09-09: the rule for 11500 pointed
# at the right IP and still refused connections, because IP Helper had not been
# restarted since the adapter came back.
#
# Run in an ELEVATED PowerShell. Re-run after every `wsl --shutdown`, or use
# -Install to have Windows do it for you at logon.

param(
  [int[]] $Ports = @(11434, 11500, 8188),  # 8188 = ComfyUI for the Mac (2026-11-10)
  [switch] $Install
)

$ErrorActionPreference = 'Stop'
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
      ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Error "Run this in an elevated PowerShell (right-click, Run as administrator)."
}

# --- where WSL is right now --------------------------------------------------
$wslIp = (wsl.exe -d Ubuntu -e sh -c "hostname -I | awk '{print `$1}'").Trim()
if (-not $wslIp) { Write-Error "could not read the WSL IP -- is the Ubuntu distro running?" }

$net = Get-NetIPConfiguration |
       Where-Object { $_.IPv4DefaultGateway -and $_.NetAdapter.Status -eq 'Up' } |
       Select-Object -First 1
$hostIp = $net.IPv4Address.IPAddress
$len    = $net.IPv4Address.PrefixLength
$subnet = "$($hostIp -replace '\.\d+$', '.0')/$len"

Write-Host "host $hostIp/$len   ->   WSL $wslIp"

foreach ($p in $Ports) {
  # delete first: an entry pointing at a stale WSL IP is worse than none
  netsh interface portproxy delete v4tov4 listenaddress=$hostIp listenport=$p 2>$null | Out-Null
  netsh interface portproxy add v4tov4 `
        listenaddress=$hostIp listenport=$p `
        connectaddress=$wslIp connectport=$p | Out-Null

  $name = "agent-ci gateway LAN $p"
  Get-NetFirewallRule -DisplayName $name -ErrorAction SilentlyContinue | Remove-NetFirewallRule
  New-NetFirewallRule -DisplayName $name -Direction Inbound -Action Allow `
      -Protocol TCP -LocalPort $p -RemoteAddress $subnet -Profile Private,Domain | Out-Null
  Write-Host "  :$p  portproxy + firewall (from $subnet only)"
}

# --- the step that is actually missing when this "mysteriously" stops working -
Restart-Service iphlpsvc -Force
Start-Sleep -Seconds 2
Write-Host "IP Helper restarted (this is what rebinds the listeners)"

# --- prove it, rather than claiming it ---------------------------------------
Write-Host ""
foreach ($p in $Ports) {
  $ok = (Test-NetConnection -ComputerName $hostIp -Port $p -WarningAction SilentlyContinue).TcpTestSucceeded
  "{0,-6} {1}" -f ":$p", $(if ($ok) { "reachable on $hostIp" } else { "STILL REFUSED" })
}

if ($Install) {
  # NAT hands out a new WSL IP on every boot, so a one-shot fix is a fix with a
  # short life. Re-run at logon.
  $me = $MyInvocation.MyCommand.Path
  $action  = New-ScheduledTaskAction -Execute 'powershell.exe' `
             -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$me`""
  $trigger = New-ScheduledTaskTrigger -AtLogOn
  $princ   = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest
  Register-ScheduledTask -TaskName 'agent-ci gateway LAN' -Action $action `
      -Trigger $trigger -Principal $princ -Force | Out-Null
  Write-Host ""
  Write-Host "installed: re-runs at logon, so a wsl --shutdown no longer breaks LAN access"
}

Write-Host ""
Write-Host "Dashboard from a phone on the same wifi:"
Write-Host "  http://${hostIp}:11434/?t=<token>"
Write-Host "  token: wsl -d Ubuntu -e cat /home/cmadrigal/ollama-gateway/lan-token.txt"
