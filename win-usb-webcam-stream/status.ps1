$ErrorActionPreference = "Stop"

$ffmpeg = Get-Process -Name ffmpeg -ErrorAction SilentlyContinue
$mediamtx = Get-Process -Name mediamtx -ErrorAction SilentlyContinue

if ($ffmpeg) {
    Write-Host "FFmpeg: Running (PID: $($ffmpeg.Id))" -ForegroundColor Green
} else {
    Write-Host "FFmpeg: Not running" -ForegroundColor Red
}

if ($mediamtx) {
    Write-Host "MediaMTX: Running (PID: $($mediamtx.Id))" -ForegroundColor Green
} else {
    Write-Host "MediaMTX: Not running" -ForegroundColor Red
}

if ($ffmpeg -and $mediamtx) {
    $localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notmatch 'Loopback' -and $_.IPAddress -notmatch '^169' -and $_.InterfaceAlias -notmatch 'vEthernet' } | Select-Object -First 1).IPAddress
    Write-Host ""
    Write-Host "RTSP URL: rtsp://${localIP}:8554/webcam" -ForegroundColor Yellow
}
