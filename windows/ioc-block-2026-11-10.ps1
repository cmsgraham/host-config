# IOC block for the 2026-11-09 "Lichii" infection (+ the 2026-10-26 Binance-theft infra).
# Idempotent: re-running replaces the marked hosts block and the "IOC-2026-11-10" firewall rules.
# Evidence: \\wsl$\Ubuntu\home\cmadrigal\malware-lab\evidence\2026-11-10-win-stealer
$ErrorActionPreference = 'Stop'
$log = "$env:USERPROFILE\ioc-block-2026-11-10.log"
Start-Transcript -Path $log -Force | Out-Null
try {
    $domains = @(
        # stage 0/1: fake emulator site and the dropper host
        'lichii.org', 'www.lichii.org', 'tresoctavos.com.mx', 'www.tresoctavos.com.mx',
        # C2 seen in charmap.exe / node.exe memory
        'cosmicsky.xyz', 'www.cosmicsky.xyz', 'cosmicsky.cc', 'www.cosmicsky.cc',
        'realmadridistats.org', 'www.realmadridistats.org', 'tshn.edu.vn', 'www.tshn.edu.vn',
        # remote-access tunnel injected into calc.exe (cloudflared quick tunnel)
        'notify-wild-art-practice.trycloudflare.com', 'api.trycloudflare.com', 'login.trycloudflare.com',
        'region1.v2.argotunnel.com', 'region2.v2.argotunnel.com',
        'us-region1.v2.argotunnel.com', 'us-region2.v2.argotunnel.com',
        'update.argotunnel.com', 'staging-update.argotunnel.com', 'cfd-features.argotunnel.com',
        'management.argotunnel.com',
        # 2026-10-26 forensic report (Binance theft)
        'ngc246.com', 'www.ngc246.com', 'easybooters.com', 'www.easybooters.com', 'poribax.com', 'www.poribax.com'
    )
    $hosts = "$env:windir\System32\drivers\etc\hosts"
    Copy-Item $hosts "$hosts.bak-2026-11-10" -Force
    $attr = (Get-Item $hosts).Attributes
    (Get-Item $hosts).Attributes = 'Normal'
    $text = [IO.File]::ReadAllText($hosts)
    $text = [regex]::Replace($text, '(?s)\r?\n?# BEGIN IOC-2026-11-10.*?# END IOC-2026-11-10\r?\n?', "`r`n")
    $block = "# BEGIN IOC-2026-11-10 (malware infra, see ioc-block-2026-11-10.ps1)`r`n" +
             (($domains | ForEach-Object { "0.0.0.0 $_`r`n:: $_" }) -join "`r`n") + "`r`n# END IOC-2026-11-10`r`n"
    [IO.File]::WriteAllText($hosts, $text.TrimEnd() + "`r`n`r`n" + $block, [Text.Encoding]::ASCII)
    (Get-Item $hosts).Attributes = $attr
    ipconfig /flushdns | Out-Null
    "hosts: $($domains.Count) names blocked"

    # Dedicated (non-shared) attacker IPs. Cloudflare-fronted names are NOT blocked by IP
    # (shared edge IPs would break unrelated sites); the hosts entries cover them.
    $ips = @(
        '203.161.45.26',    # lichii.org
        '162.241.60.131',   # tresoctavos.com.mx (compromised shared host)
        '66.29.148.189',    # realmadridistats.org
        '103.56.160.25',    # tshn.edu.vn
        '135.181.51.128/28',# Hetzner CursedChrome panel (10-26 report)
        '88.218.188.83',    # CursedChrome proxy cert IP (10-26 report)
        '193.37.69.130'     # erans.ru NS for poribax.com (10-26 report)
    )
    # Cloudflare Tunnel edge: only cloudflared uses these ranges / port 7844 (nothing here uses cloudflared)
    $tunnelEdge = @('198.41.192.0/24', '198.41.200.0/24')

    Get-NetFirewallRule -DisplayName 'IOC-2026-11-10*' -ErrorAction SilentlyContinue | Remove-NetFirewallRule
    New-NetFirewallRule -DisplayName 'IOC-2026-11-10 block out' -Direction Outbound -Action Block -RemoteAddress $ips -Profile Any | Out-Null
    New-NetFirewallRule -DisplayName 'IOC-2026-11-10 block in'  -Direction Inbound  -Action Block -RemoteAddress $ips -Profile Any | Out-Null
    New-NetFirewallRule -DisplayName 'IOC-2026-11-10 cf-tunnel edge out' -Direction Outbound -Action Block -RemoteAddress $tunnelEdge -Profile Any | Out-Null
    New-NetFirewallRule -DisplayName 'IOC-2026-11-10 cf-tunnel 7844 tcp' -Direction Outbound -Action Block -Protocol TCP -RemotePort 7844 -Profile Any | Out-Null
    New-NetFirewallRule -DisplayName 'IOC-2026-11-10 cf-tunnel 7844 udp' -Direction Outbound -Action Block -Protocol UDP -RemotePort 7844 -Profile Any | Out-Null
    "firewall: " + (Get-NetFirewallRule -DisplayName 'IOC-2026-11-10*' | Measure-Object).Count + " rules"
    'RESULT: OK'
} catch {
    "RESULT: FAILED: $_"
} finally {
    Stop-Transcript | Out-Null
}
