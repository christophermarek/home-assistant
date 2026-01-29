$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "USB Webcam RTSP Stream Setup" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Step 1: Setting up directories..." -ForegroundColor Yellow
$binDir = Join-Path $PSScriptRoot "bin"
if (-not (Test-Path $binDir)) {
    New-Item -ItemType Directory -Path $binDir | Out-Null
    Write-Host "  Created bin/ directory" -ForegroundColor Green
} else {
    Write-Host "  bin/ directory already exists" -ForegroundColor Green
}

Write-Host ""
Write-Host "Step 2: Copying ffmpeg from Downloads..." -ForegroundColor Yellow
$downloadsPath = Join-Path $env:USERPROFILE "Downloads"
$ffmpegDest = Join-Path $binDir "ffmpeg.exe"

$ffmpegSource = $null
$directFfmpeg = Join-Path $downloadsPath "ffmpeg.exe"
if (Test-Path $directFfmpeg) {
    $ffmpegSource = $directFfmpeg
} else {
    $ffmpegDirs = Get-ChildItem -Path $downloadsPath -Directory -Filter "*ffmpeg*" -ErrorAction SilentlyContinue
    foreach ($dir in $ffmpegDirs) {
        $binPath = Join-Path $dir.FullName "bin\ffmpeg.exe"
        if (Test-Path $binPath) {
            $ffmpegSource = $binPath
            break
        }
        $recursiveFfmpeg = Get-ChildItem -Path $dir.FullName -Filter "ffmpeg.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($recursiveFfmpeg) {
            $ffmpegSource = $recursiveFfmpeg.FullName
            break
        }
    }
}

if ($ffmpegSource) {
    if (Test-Path $ffmpegDest) {
        Write-Host "  ffmpeg.exe already exists in bin/, skipping copy" -ForegroundColor Yellow
    } else {
        Copy-Item -Path $ffmpegSource -Destination $ffmpegDest -Force
        Write-Host "  Copied ffmpeg.exe to bin/ from: $ffmpegSource" -ForegroundColor Green
    }
} else {
    Write-Host "  WARNING: ffmpeg.exe not found in Downloads" -ForegroundColor Yellow
    Write-Host "  Please ensure ffmpeg.exe is in: $downloadsPath" -ForegroundColor Yellow
    Write-Host "  You can download it from: https://ffmpeg.org/download.html" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Step 3: Copying MediaMTX from Downloads..." -ForegroundColor Yellow
$mediamtxDest = Join-Path $binDir "mediamtx.exe"

$mediamtxSource = $null
$directMediamtx = Join-Path $downloadsPath "mediamtx.exe"
if (Test-Path $directMediamtx) {
    $mediamtxSource = $directMediamtx
} else {
    $mediamtxDirs = Get-ChildItem -Path $downloadsPath -Directory -Filter "*mediamtx*" -ErrorAction SilentlyContinue
    foreach ($dir in $mediamtxDirs) {
        $exePath = Join-Path $dir.FullName "mediamtx.exe"
        if (Test-Path $exePath) {
            $mediamtxSource = $exePath
            break
        }
        $recursiveMediamtx = Get-ChildItem -Path $dir.FullName -Filter "mediamtx.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($recursiveMediamtx) {
            $mediamtxSource = $recursiveMediamtx.FullName
            break
        }
    }
}

if ($mediamtxSource) {
    if (Test-Path $mediamtxDest) {
        Write-Host "  mediamtx.exe already exists in bin/, skipping copy" -ForegroundColor Yellow
    } else {
        Copy-Item -Path $mediamtxSource -Destination $mediamtxDest -Force
        Write-Host "  Copied mediamtx.exe to bin/ from: $mediamtxSource" -ForegroundColor Green
    }
} else {
    Write-Host "  ERROR: mediamtx.exe not found in Downloads" -ForegroundColor Red
    Write-Host "  Please ensure mediamtx.exe is in: $downloadsPath" -ForegroundColor Yellow
    Write-Host "  You can download it from: https://github.com/bluenviron/mediamtx/releases" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path $ffmpegDest)) {
    Write-Host ""
    Write-Host "ERROR: Setup incomplete - ffmpeg.exe is missing" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "To start the stream, run:" -ForegroundColor White
Write-Host "  .\start.ps1" -ForegroundColor Yellow
Write-Host ""
