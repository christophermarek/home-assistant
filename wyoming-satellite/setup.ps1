param(
    [switch]$SkipWSL
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "Wyoming Satellite for Windows (WSL)" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

if (-not $SkipWSL) {
    Write-Host "Step 1: Checking WSL installation..." -ForegroundColor Yellow
    
    $wslList = wsl --list --quiet 2>&1
    if ($wslList -match "Ubuntu") {
        Write-Host "  Ubuntu is already installed" -ForegroundColor Green
    } else {
        Write-Host "  Installing WSL with Ubuntu..." -ForegroundColor Yellow
        Write-Host "  This requires Administrator privileges and a restart." -ForegroundColor Yellow
        Write-Host ""
        
        $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if (-not $isAdmin) {
            Write-Host "ERROR: Run this script as Administrator to install WSL" -ForegroundColor Red
            Write-Host "Right-click PowerShell > Run as Administrator" -ForegroundColor Red
            exit 1
        }
        
        wsl --install -d Ubuntu
        Write-Host ""
        Write-Host "WSL installed. Please restart your computer, then:" -ForegroundColor Green
        Write-Host "  1. Open Ubuntu from Start menu" -ForegroundColor White
        Write-Host "  2. Create a username and password" -ForegroundColor White
        Write-Host "  3. Run this script again with: .\setup.ps1 -SkipWSL" -ForegroundColor White
        exit 0
    }
}

Write-Host ""
Write-Host "Step 2: Installing dependencies in Ubuntu..." -ForegroundColor Yellow
wsl -d Ubuntu -- bash -c "sudo apt update && sudo apt install -y python3 python3-pip python3-venv ffmpeg git alsa-utils"

Write-Host ""
Write-Host "Step 3: Cloning wyoming-satellite..." -ForegroundColor Yellow
wsl -d Ubuntu -- bash -c "if [ -d ~/wyoming-satellite ]; then echo 'Already exists, updating...'; cd ~/wyoming-satellite && git pull; else git clone https://github.com/rhasspy/wyoming-satellite.git ~/wyoming-satellite; fi"

Write-Host ""
Write-Host "Step 4: Setting up Python environment..." -ForegroundColor Yellow
wsl -d Ubuntu -- bash -c "cd ~/wyoming-satellite && python3 -m venv .venv && source .venv/bin/activate && pip install --upgrade pip && pip install -e ."

Write-Host ""
Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "To start the satellite, run:" -ForegroundColor White
Write-Host "  .\start.ps1" -ForegroundColor Yellow
Write-Host ""
Write-Host "Then add it to Home Assistant:" -ForegroundColor White
Write-Host "  Settings > Devices & Services > Add Integration > Wyoming Protocol" -ForegroundColor White

$localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notmatch 'Loopback' -and $_.IPAddress -notmatch '^169' -and $_.InterfaceAlias -notmatch 'vEthernet' } | Select-Object -First 1).IPAddress
Write-Host "  Host: $localIP" -ForegroundColor Yellow
Write-Host "  Port: 10700" -ForegroundColor Yellow
Write-Host ""
