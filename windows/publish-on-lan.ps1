# Publish the agent-ci gateway on the local network.
# Run ONCE in an ELEVATED PowerShell on the Windows host.
#
# What it does, and nothing more:
#   1. switches WSL to mirrored networking, so a service bound to 0.0.0.0
#      inside WSL appears on this machine's own LAN address
#   2. opens TCP 11434 to the LOCAL SUBNET ONLY (not the internet)
#   3. tightens the old rule that allowed the whole 172.16/12 range
#
# Afterwards: wsl --shutdown, then start WSL again. The dashboard is at
#   http://<this machine's LAN IP>:11434/?t=<token from ~/ollama-gateway/lan-token.txt>

$ErrorActionPreference = 'Stop'
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
      ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Error "Run this in an elevated PowerShell (right-click, Run as administrator)."
}

# --- 1. mirrored networking -------------------------------------------------
$cfg = "$env:USERPROFILE\.wslconfig"
$text = if (Test-Path $cfg) { Get-Content $cfg -Raw } else { "[wsl2]`n" }
if ($text -match '(?m)^\s*networkingMode\s*=') {
  $text = $text -replace '(?m)^\s*networkingMode\s*=.*$', 'networkingMode=mirrored'
} else {
  $text = $text -replace '(?m)^\[wsl2\]', "[wsl2]`nnetworkingMode=mirrored"
}
# the note that pinned this to NAT is obsolete: Ollama moved into WSL on 2026-09-03
$text = $text -replace '(?m)^# Keep NAT networking.*$', '# Mirrored since the model stack moved into WSL; NAT is no longer needed.'
$text = $text -replace '(?m)^# depends on it\. Do not switch to mirrored without updating that\.$', ''
Set-Content -Path $cfg -Value $text -Encoding UTF8
Write-Host "networkingMode=mirrored written to $cfg"

# --- 2. the local subnet, and only it ---------------------------------------
$net = Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -and $_.NetAdapter.Status -eq 'Up' } | Select-Object -First 1
$ip  = $net.IPv4Address.IPAddress
$len = $net.IPv4Address.PrefixLength
$subnet = "$($ip -replace '\.\d+$', '.0')/$len"

Get-NetFirewallRule -DisplayName 'agent-ci gateway (LAN)' -ErrorAction SilentlyContinue | Remove-NetFirewallRule
New-NetFirewallRule -DisplayName 'agent-ci gateway (LAN)' -Direction Inbound -Action Allow `
  -Protocol TCP -LocalPort 11434 -RemoteAddress $subnet -Profile Private,Domain | Out-Null
Write-Host "opened TCP 11434 to $subnet only (private and domain profiles)"

# --- 3. narrow the old WSL-range rule ---------------------------------------
Get-NetFirewallRule -DisplayName 'Ollama Gateway from WSL' -ErrorAction SilentlyContinue |
  ForEach-Object { Set-NetFirewallRule -InputObject $_ -RemoteAddress '127.0.0.1' }

Write-Host ""
Write-Host "Now run:  wsl --shutdown        (closes VS Code's WSL session; reopen it after)"
Write-Host "Then from a phone on the same wifi:  http://$ip`:11434/"
