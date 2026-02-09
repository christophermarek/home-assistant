param(
    [string]$CameraName,
    [int]$Port = 8554
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "USB Webcam RTSP Stream" -ForegroundColor Cyan
Write-Host "======================" -ForegroundColor Cyan
Write-Host ""

$binDir = Join-Path $PSScriptRoot "bin"
$ffmpegPath = Join-Path $binDir "ffmpeg.exe"
$mediamtxPath = Join-Path $binDir "mediamtx.exe"

if (-not (Test-Path $ffmpegPath)) {
    Write-Host "ERROR: ffmpeg.exe not found in bin/ directory" -ForegroundColor Red
    Write-Host "Run setup.ps1 first to copy ffmpeg from Downloads" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path $mediamtxPath)) {
    Write-Host "ERROR: mediamtx.exe not found in bin/ directory" -ForegroundColor Red
    Write-Host "Run setup.ps1 first to copy MediaMTX from Downloads" -ForegroundColor Yellow
    exit 1
}

$existingFfmpeg = Get-Process -Name ffmpeg -ErrorAction SilentlyContinue
$existingMediamtx = Get-Process -Name mediamtx -ErrorAction SilentlyContinue

if ($existingFfmpeg -or $existingMediamtx) {
    Write-Host "WARNING: Stream processes are already running" -ForegroundColor Yellow
    Write-Host "Run .\stop.ps1 first to stop existing streams" -ForegroundColor Yellow
    exit 1
}

Write-Host "Step 1: Detecting USB webcams..." -ForegroundColor Yellow
$tempFile = [System.IO.Path]::GetTempFileName()
try {
    $process = Start-Process -FilePath $ffmpegPath -ArgumentList @("-list_devices", "true", "-f", "dshow", "-i", "dummy") -RedirectStandardError $tempFile -NoNewWindow -Wait -PassThru
    $deviceListOutput = Get-Content $tempFile -Raw
} finally {
    Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
}

$cameras = @()
$lines = $deviceListOutput -split "`r?`n"
foreach ($line in $lines) {
    if ($line -match '\[dshow[^\]]+\]\s+"([^"]+)"\s+\(video\)') {
        $cameraName = $matches[1]
        if ($cameraName -and $cameraName -ne "dummy") {
            if ($cameras -notcontains $cameraName) {
                $cameras += $cameraName
            }
        }
    }
}

if ($cameras.Count -eq 0) {
    Write-Host "ERROR: No USB webcams detected" -ForegroundColor Red
    Write-Host "Please ensure a USB webcam is connected and try again" -ForegroundColor Yellow
    exit 1
}

Write-Host "  Found $($cameras.Count) webcam(s)" -ForegroundColor Green

$selectedCamera = $null

if ($PSBoundParameters.ContainsKey('CameraName') -and $CameraName) {
    $selectedCamera = $cameras | Where-Object { $_ -eq $CameraName } | Select-Object -First 1
    if (-not $selectedCamera) {
        Write-Host "ERROR: Camera '$CameraName' not found" -ForegroundColor Red
        Write-Host "Available cameras:" -ForegroundColor Yellow
        for ($i = 0; $i -lt $cameras.Count; $i++) {
            Write-Host "  $($i + 1). $($cameras[$i])" -ForegroundColor White
        }
        exit 1
    }
    Write-Host "  Using specified camera: $selectedCamera" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Please select a webcam:" -ForegroundColor Yellow
    for ($i = 0; $i -lt $cameras.Count; $i++) {
        Write-Host "  $($i + 1). $($cameras[$i])" -ForegroundColor White
    }
    Write-Host ""
    
    do {
        $selection = Read-Host "Enter number (1-$($cameras.Count))"
        if ([string]::IsNullOrWhiteSpace($selection)) {
            Write-Host "Please enter a number" -ForegroundColor Yellow
            continue
        }
        try {
            $index = [int]$selection - 1
            if ($index -ge 0 -and $index -lt $cameras.Count) {
                $selectedCamera = $cameras[$index]
                break
            } else {
                Write-Host "ERROR: Invalid selection. Please enter a number between 1 and $($cameras.Count)" -ForegroundColor Red
            }
        } catch {
            Write-Host "ERROR: Invalid input. Please enter a number" -ForegroundColor Red
        }
    } while (-not $selectedCamera)
    
    Write-Host "  Selected: $selectedCamera" -ForegroundColor Green
}

Write-Host ""
Write-Host "Step 2: Setting up screenshot directory..." -ForegroundColor Yellow
$screenshotDir = Join-Path $PSScriptRoot "screenshots"
if (-not (Test-Path $screenshotDir)) {
    New-Item -ItemType Directory -Path $screenshotDir | Out-Null
}
$streamTimestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$folderName = "${selectedCamera}_${streamTimestamp}"
$folderName = $folderName -replace '[<>:"/\\|?*]', '_'
$streamFolder = Join-Path $screenshotDir $folderName
New-Item -ItemType Directory -Path $streamFolder -Force | Out-Null
Write-Host "  Screenshot directory: $streamFolder" -ForegroundColor Green

Write-Host ""
Write-Host "Step 3: Getting network information..." -ForegroundColor Yellow
$localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notmatch 'Loopback' -and $_.IPAddress -notmatch '^169' -and $_.InterfaceAlias -notmatch 'vEthernet' } | Select-Object -First 1).IPAddress
Write-Host "  Windows IP: $localIP" -ForegroundColor White

Write-Host ""
Write-Host "Step 4: Configuring firewall..." -ForegroundColor Yellow
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
    $ruleExists = netsh advfirewall firewall show rule name="USB Webcam RTSP" 2>$null
    if (-not $ruleExists) {
        netsh advfirewall firewall add rule name="USB Webcam RTSP" dir=in action=allow protocol=TCP localport=$Port | Out-Null
        Write-Host "  Firewall rule added" -ForegroundColor Green
    } else {
        Write-Host "  Firewall rule already exists" -ForegroundColor Green
    }
} else {
    Write-Host "  WARNING: Not running as Admin - firewall rule may not be configured" -ForegroundColor Yellow
    Write-Host "  Run as Administrator for external access" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Step 5: Starting MediaMTX server..." -ForegroundColor Yellow
$configFile = Join-Path $PSScriptRoot "mediamtx.yml"
if (Test-Path $configFile) {
    $mediamtxProcess = Start-Process -FilePath $mediamtxPath -ArgumentList $configFile -PassThru -WindowStyle Hidden -WorkingDirectory $PSScriptRoot
} else {
    $mediamtxProcess = Start-Process -FilePath $mediamtxPath -PassThru -WindowStyle Hidden -WorkingDirectory $PSScriptRoot
}

$mediamtxTimeout = 5
$mediamtxElapsed = 0
while ($mediamtxElapsed -lt $mediamtxTimeout) {
    Start-Sleep -Milliseconds 500
    $mediamtxElapsed += 0.5
    if ($mediamtxProcess.HasExited) {
        Write-Host "ERROR: MediaMTX failed to start" -ForegroundColor Red
        Write-Host "Check if port $Port is already in use" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host "  MediaMTX started (PID: $($mediamtxProcess.Id))" -ForegroundColor Green

Write-Host ""
Write-Host "Step 6: Starting ffmpeg stream..." -ForegroundColor Yellow
$ffmpegArgs = @(
    "-f", "dshow",
    "-i", "video=`"$selectedCamera`"",
    "-pix_fmt", "yuv420p",
    "-c:v", "libx264",
    "-profile:v", "baseline",
    "-level", "3.0",
    "-preset", "ultrafast",
    "-tune", "zerolatency",
    "-rtsp_transport", "tcp",
    "-f", "rtsp",
    "rtsp://localhost:${Port}/webcam"
)

$ffmpegProcess = Start-Process -FilePath $ffmpegPath -ArgumentList $ffmpegArgs -NoNewWindow -PassThru

$ffmpegTimeout = 5
$ffmpegElapsed = 0
while ($ffmpegElapsed -lt $ffmpegTimeout) {
    Start-Sleep -Milliseconds 500
    $ffmpegElapsed += 0.5
    if ($ffmpegProcess.HasExited) {
        Write-Host "ERROR: ffmpeg failed to start" -ForegroundColor Red
        if (-not $mediamtxProcess.HasExited) {
            Stop-Process -Id $mediamtxProcess.Id -Force -ErrorAction SilentlyContinue
        }
        exit 1
    }
}

Write-Host "  FFmpeg started (PID: $($ffmpegProcess.Id))" -ForegroundColor Green

Write-Host ""
Write-Host "Step 7: Capturing start screenshot..." -ForegroundColor Yellow
$startScreenshot = Join-Path $streamFolder "start_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').jpg"
$startScreenshot = [System.IO.Path]::GetFullPath($startScreenshot)
$screenshotArgs = @(
    "-rtsp_transport", "tcp",
    "-i", "rtsp://localhost:${Port}/webcam",
    "-vframes", "1",
    "-q:v", "2",
    "-y",
    $startScreenshot
)
$screenshotProcess = Start-Process -FilePath $ffmpegPath -ArgumentList $screenshotArgs -NoNewWindow -Wait -PassThru
if ($screenshotProcess.ExitCode -eq 0 -and (Test-Path $startScreenshot)) {
    Write-Host "  Start screenshot saved: $startScreenshot" -ForegroundColor Green
} else {
    Write-Host "  WARNING: Failed to capture start screenshot" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Step 8: Setting up hourly screenshot capture..." -ForegroundColor Yellow
$script:screenshotJob = Start-Job -ScriptBlock {
    param($ffmpegPath, $rtspUrl, $streamFolder)
    Start-Sleep -Seconds 3600
    while ($true) {
        $screenshotFile = Join-Path $streamFolder "hourly_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').jpg"
        $args = @(
            "-rtsp_transport", "tcp",
            "-i", $rtspUrl,
            "-vframes", "1",
            "-q:v", "2",
            "-y",
            $screenshotFile
        )
        $proc = Start-Process -FilePath $ffmpegPath -ArgumentList $args -Wait -NoNewWindow -PassThru -ErrorAction SilentlyContinue
        if ($proc -and $proc.ExitCode -eq 0 -and (Test-Path $screenshotFile)) {
            Write-Output "Screenshot saved: $screenshotFile"
        }
        Start-Sleep -Seconds 3600
    }
} -ArgumentList $ffmpegPath, "rtsp://localhost:${Port}/webcam", $streamFolder
Write-Host "  Hourly screenshot capture started (first capture in 1 hour)" -ForegroundColor Green

Write-Host ""
Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Stream is running!" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Camera: $selectedCamera" -ForegroundColor White
Write-Host "RTSP URL: rtsp://${localIP}:${Port}/webcam" -ForegroundColor Yellow
Write-Host "Screenshots: $streamFolder" -ForegroundColor White
Write-Host ""
Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
Write-Host ""

$script:mediamtxProcess = $mediamtxProcess
$script:ffmpegProcess = $ffmpegProcess
$script:streamFolder = $streamFolder

[Console]::TreatControlCAsInput = $false
try {
    while (-not $script:ffmpegProcess.HasExited) {
        Start-Sleep -Seconds 1
    }
} catch {
} finally {
    Write-Host ""
    Write-Host "Stopping stream..." -ForegroundColor Yellow
    
    if ($script:screenshotJob) {
        Stop-Job $script:screenshotJob -ErrorAction SilentlyContinue
        Remove-Job $script:screenshotJob -ErrorAction SilentlyContinue
        Write-Host "  Stopped screenshot capture" -ForegroundColor Green
    }
    
    Write-Host "  Capturing end screenshot..." -ForegroundColor Yellow
    if ($script:streamFolder) {
        $endScreenshot = Join-Path $script:streamFolder "end_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').jpg"
        $endScreenshot = [System.IO.Path]::GetFullPath($endScreenshot)
        $screenshotArgs = @(
            "-rtsp_transport", "tcp",
            "-i", "rtsp://localhost:${Port}/webcam",
            "-vframes", "1",
            "-q:v", "2",
            "-y",
            $endScreenshot
        )
        $screenshotProcess = Start-Process -FilePath $ffmpegPath -ArgumentList $screenshotArgs -NoNewWindow -Wait -PassThru -ErrorAction SilentlyContinue
        if ($screenshotProcess -and $screenshotProcess.ExitCode -eq 0 -and (Test-Path $endScreenshot)) {
            Write-Host "  End screenshot saved: $endScreenshot" -ForegroundColor Green
        } else {
            Write-Host "  WARNING: Failed to capture end screenshot" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  WARNING: Stream folder not set, skipping end screenshot" -ForegroundColor Yellow
    }
    
    if ($script:ffmpegProcess -and -not $script:ffmpegProcess.HasExited) {
        Stop-Process -Id $script:ffmpegProcess.Id -Force -ErrorAction SilentlyContinue
        Write-Host "  Stopped FFmpeg" -ForegroundColor Green
    }
    
    if ($script:mediamtxProcess -and -not $script:mediamtxProcess.HasExited) {
        Stop-Process -Id $script:mediamtxProcess.Id -Force -ErrorAction SilentlyContinue
        Write-Host "  Stopped MediaMTX" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "Stream stopped" -ForegroundColor Green
    Write-Host "Screenshots saved in: $($script:streamFolder)" -ForegroundColor Cyan
}
