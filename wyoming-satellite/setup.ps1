param(
    [Parameter(Mandatory=$true)]
    [string]$HA_HOST,
    
    [Parameter(Mandatory=$true)]
    [string]$HA_TOKEN
)

$ErrorActionPreference = "Stop"

Write-Host "Home Assistant Satellite for Windows" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$VENV_DIR = ".venv"

Write-Host "Checking Python installation..."
try {
    $pythonVersion = python --version 2>&1
    Write-Host "Found: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Python is not installed." -ForegroundColor Red
    Write-Host "Please install Python 3.9+ from https://python.org"
    Write-Host "Make sure to check 'Add Python to PATH' during installation"
    exit 1
}

Write-Host "Checking FFmpeg installation..."
try {
    $null = ffmpeg -version 2>&1
    Write-Host "FFmpeg found" -ForegroundColor Green
} catch {
    Write-Host "ERROR: FFmpeg is not installed or not in PATH." -ForegroundColor Red
    Write-Host ""
    Write-Host "To install FFmpeg:"
    Write-Host "  winget install ffmpeg"
    Write-Host "  -or-"
    Write-Host "  choco install ffmpeg"
    Write-Host "  -or-"
    Write-Host "  Download from https://ffmpeg.org/download.html"
    exit 1
}

if (-not (Test-Path $VENV_DIR)) {
    Write-Host "Creating virtual environment..."
    python -m venv $VENV_DIR
}

Write-Host "Activating virtual environment..."
& "$VENV_DIR\Scripts\Activate.ps1"

Write-Host "Installing dependencies..."
pip install --quiet --upgrade pip
pip install --quiet sounddevice
pip install --quiet homeassistant-satellite

$localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notmatch 'Loopback' -and $_.IPAddress -notmatch '^169' } | Select-Object -First 1).IPAddress

Write-Host ""
Write-Host "Starting Home Assistant Satellite..." -ForegroundColor Green
Write-Host "Host: $HA_HOST"
Write-Host "Local IP: $localIP"
Write-Host ""
Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
Write-Host ""

python -m homeassistant_satellite --host $HA_HOST --token $HA_TOKEN
