param(
    [string]$Name = "Windows Satellite",
    [int]$Port = 10700
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "Wyoming Satellite" -ForegroundColor Cyan
Write-Host "=================" -ForegroundColor Cyan
Write-Host ""

$wslList = wsl --list --quiet 2>&1
if (-not ($wslList -match "Ubuntu")) {
    Write-Host "ERROR: Ubuntu not installed. Run setup.ps1 first." -ForegroundColor Red
    exit 1
}

$wslIP = (wsl -d Ubuntu -- hostname -I).Trim().Split()[0]
$localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notmatch 'Loopback' -and $_.IPAddress -notmatch '^169' -and $_.InterfaceAlias -notmatch 'vEthernet' } | Select-Object -First 1).IPAddress

Write-Host "Setting up port forwarding..." -ForegroundColor Yellow
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
    netsh interface portproxy delete v4tov4 listenport=$Port listenaddress=0.0.0.0 2>$null
    netsh interface portproxy add v4tov4 listenport=$Port listenaddress=0.0.0.0 connectport=$Port connectaddress=$wslIP
    
    $ruleExists = netsh advfirewall firewall show rule name="Wyoming Satellite" 2>$null
    if (-not $ruleExists) {
        netsh advfirewall firewall add rule name="Wyoming Satellite" dir=in action=allow protocol=TCP localport=$Port
    }
    Write-Host "  Port forwarding configured" -ForegroundColor Green
} else {
    Write-Host "  WARNING: Not running as Admin - port forwarding may not work" -ForegroundColor Yellow
    Write-Host "  Run as Administrator for external access" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Starting satellite..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Name: $Name" -ForegroundColor White
Write-Host "WSL IP: $wslIP" -ForegroundColor White
Write-Host "Windows IP: $localIP" -ForegroundColor White
Write-Host ""
Write-Host "Add to Home Assistant:" -ForegroundColor Green
Write-Host "  Settings > Devices & Services > Add Integration > Wyoming Protocol" -ForegroundColor White
Write-Host "  Host: $localIP" -ForegroundColor Yellow
Write-Host "  Port: $Port" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
Write-Host ""

$cmd = "cd ~/wyoming-satellite && source .venv/bin/activate && python -m wyoming_satellite --name '$Name' --uri tcp://0.0.0.0:$Port --mic-command 'parec --rate=16000 --channels=1 --format=s16le --raw' --snd-command 'paplay --rate=22050 --channels=1 --format=s16le --raw'"

wsl -d Ubuntu -- bash -c $cmd
