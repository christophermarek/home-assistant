$ErrorActionPreference = "Stop"

Write-Host "Stopping stream..." -ForegroundColor Yellow

$stopped = $false

$ffmpegProcesses = Get-Process -Name ffmpeg -ErrorAction SilentlyContinue
if ($ffmpegProcesses) {
    $ffmpegProcesses | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Host "  Stopped FFmpeg" -ForegroundColor Green
    $stopped = $true
}

$mediamtxProcesses = Get-Process -Name mediamtx -ErrorAction SilentlyContinue
if ($mediamtxProcesses) {
    $mediamtxProcesses | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Host "  Stopped MediaMTX" -ForegroundColor Green
    $stopped = $true
}

if (-not $stopped) {
    Write-Host "  No running processes found" -ForegroundColor Yellow
} else {
    Write-Host "Stream stopped" -ForegroundColor Green
}
