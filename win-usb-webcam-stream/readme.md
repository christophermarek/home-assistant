# USB Webcam RTSP Stream for Windows

RTSP streaming solution for USB webcams using FFmpeg and MediaMTX (Windows native).

## Requirements

- Windows 10/11
- FFmpeg executable in Downloads folder
- MediaMTX executable in Downloads folder
- USB webcam connected

## Quick Start

### 1. Setup

Open PowerShell and run:

```powershell
.\setup.ps1
```

Or use Make:

```powershell
make setup
```

This will:
- Create bin/ directory
- Copy ffmpeg.exe from Downloads to bin/ directory
- Copy mediamtx.exe from Downloads to bin/ directory

### 2. Start Stream

```powershell
.\start.ps1
```

Or use Make:

```powershell
make start
```

This will:
- Detect connected USB webcams
- Prompt you to select a webcam
- Start MediaMTX server (Windows native)
- Start FFmpeg stream from selected webcam
- Create a unique folder for screenshots (camera name + timestamp)
- Capture a screenshot at stream start
- Set up hourly screenshot capture during the stream
- Capture a screenshot at stream end
- Display the RTSP stream URL and screenshot location

### 3. Connect to Stream

Use the RTSP URL shown in the terminal:

```
rtsp://[your-ip]:8554/webcam
```

### 4. Screenshots

Screenshots are automatically captured:
- **Start screenshot**: Captured when stream starts
- **Hourly screenshots**: Captured every hour during the stream
- **End screenshot**: Captured when stream stops

All screenshots are saved in `screenshots/[CameraName]_[Timestamp]/` directory with descriptive filenames.

## Commands

### Setup

```powershell
.\setup.ps1
```

Or:

```powershell
make setup
```

### Start Stream

Start with default settings:

```powershell
.\start.ps1
```

Start with specific camera:

```powershell
.\start.ps1 -CameraName "Camera Name"
```

Start on different port:

```powershell
.\start.ps1 -Port 8555
```

Or use Make:

```powershell
make start
```

### Stop Stream

Press `Ctrl+C` in the terminal, or:

```powershell
make stop
```

### Check Status

```powershell
make status
```

### View Screenshots

Screenshots are stored in the `screenshots/` directory, organized by stream session:

```
screenshots/
  └── CameraName_2024-01-15_14-30-00/
      ├── start_2024-01-15_14-30-05.jpg
      ├── hourly_2024-01-15_15-30-10.jpg
      ├── hourly_2024-01-15_16-30-15.jpg
      └── end_2024-01-15_17-45-20.jpg
```

## Troubleshooting

### No USB webcam detected

- Ensure USB webcam is connected
- Try unplugging and reconnecting the webcam
- Check Device Manager to verify the webcam is recognized
- Some built-in cameras may not appear as USB devices

### FFmpeg not found

- Ensure ffmpeg.exe is in your Downloads folder
- Run `.\setup.ps1` again to copy it to bin/
- Download FFmpeg from: https://ffmpeg.org/download.html

### MediaMTX not found

- Run `.\setup.ps1` to copy MediaMTX from Downloads
- Ensure mediamtx.exe is in your Downloads folder
- Download from: https://github.com/bluenviron/mediamtx/releases

### Port already in use

- Change the port: `.\start.ps1 -Port 8555`
- Or stop any processes using port 8554:
  ```powershell
  netstat -ano | findstr :8554
  ```

### Connection refused

Make sure Windows Firewall allows the RTSP port:
1. Open Windows Defender Firewall
2. Advanced Settings → Inbound Rules
3. New Rule → Port → TCP 8554 → Allow

Or run PowerShell as Administrator (the script will configure this automatically).

### Stream not working

- Check that both FFmpeg and MediaMTX processes are running: `.\status.ps1`
- Verify the webcam is not being used by another application
- Try a different USB port
- Check if port 8554 is already in use: `netstat -ano | findstr :8554`

### Multiple webcams

If you have multiple webcams, the script will prompt you to select one. You can also specify the camera name:

```powershell
.\start.ps1 -CameraName "USB Camera"
```

## Manual Setup

If you prefer to set things up manually:

### Copy Binaries

```powershell
Copy-Item "$env:USERPROFILE\Downloads\ffmpeg.exe" -Destination "bin\ffmpeg.exe" -Recurse
Copy-Item "$env:USERPROFILE\Downloads\mediamtx.exe" -Destination "bin\mediamtx.exe" -Recurse
```

### Run Manually

Start MediaMTX:

```powershell
.\bin\mediamtx.exe
```

In another terminal, start FFmpeg:

```powershell
.\bin\ffmpeg.exe -f dshow -i video="Camera Name" -pix_fmt yuv420p -c:v libx264 -profile:v baseline -level 3.0 -preset ultrafast -tune zerolatency -rtsp_transport tcp -f rtsp rtsp://localhost:8554/webcam
```

## Architecture

- **MediaMTX**: Runs on Windows as the RTSP server
- **FFmpeg**: Runs on Windows using DirectShow to capture from USB webcam
- Both processes run natively on Windows (no WSL required)

## References

- [FFmpeg](https://ffmpeg.org/)
- [MediaMTX](https://github.com/bluenviron/mediamtx)
