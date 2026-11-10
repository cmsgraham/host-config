# One elevated run: IOC block + LAN forward for ComfyUI (8188). Log: %USERPROFILE%\fix-2026-11-10.log
Start-Transcript -Path "$env:USERPROFILE\fix-2026-11-10.log" -Force | Out-Null
try { & "$env:USERPROFILE\ioc-block-2026-11-10.ps1" } catch { "IOC step error: $_" }
try { & "$env:USERPROFILE\publish-on-lan-nat.ps1" } catch { "PUBLISH step error: $_" }
netsh interface portproxy show v4tov4
'FIX DONE'
Stop-Transcript | Out-Null
