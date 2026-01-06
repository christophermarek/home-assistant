Home Assistant Satellite for Windows

Voice satellite using [homeassistant-satellite](https://github.com/synesthesiam/homeassistant-satellite) (cross-platform, works on Windows).

Based on [Issue #213](https://github.com/rhasspy/wyoming-satellite/issues/213): Wyoming Satellite is Linux-only, so this uses the cross-platform alternative.

## Prerequisites

### 1. Python 3.9+

Download from https://python.org

**Important:** Check "Add Python to PATH" during installation

### 2. FFmpeg

Install using one of these methods:

```cmd
winget install ffmpeg
```

or

```cmd
choco install ffmpeg
```

or download from https://ffmpeg.org/download.html and add `bin` folder to PATH

### 3. Home Assistant Token

1. Go to Home Assistant > Profile
2. Scroll to "Long-lived access tokens"
3. Click "Create token"
4. Copy and save the token

## Quick Start

```cmd
start.bat 192.168.1.100 your_token_here
```

Or PowerShell:

```powershell
.\setup.ps1 -HA_HOST 192.168.1.100 -HA_TOKEN your_token_here
```

## Commands

start satellite

```cmd
start.bat <HOME_ASSISTANT_IP> <TOKEN>
```

stop satellite

Press Ctrl+C in the terminal

list audio devices

```cmd
python -c "import sounddevice as sd; print(sd.query_devices())"
```

## How It Works

1. Captures audio from your Windows microphone using `sounddevice`
2. Streams audio to Home Assistant via API
3. Home Assistant processes with Whisper (speech-to-text)
4. Response sent back and played through your speakers via Piper (text-to-speech)

## Troubleshooting

### sounddevice installation fails

```cmd
pip install sounddevice
```

If that fails, try installing PortAudio first or use the pre-built wheel.

### No audio input

- Check Windows Sound settings > Recording
- Make sure microphone is set as default
- Run as Administrator if needed

### FFmpeg not found

Make sure FFmpeg's `bin` folder is in your system PATH:
1. Search "Environment Variables" in Windows
2. Edit PATH variable
3. Add path to FFmpeg bin folder (e.g., `C:\ffmpeg\bin`)
4. Restart terminal

### List available microphones

```cmd
python -c "import sounddevice as sd; print(sd.query_devices())"
```

## Alternative: GUI App

For a graphical interface instead of command line, download:
[Home Assistant Assist Desktop](https://github.com/home-assistant/assist-desktop/releases)

## References

- [homeassistant-satellite on PyPI](https://pypi.org/project/homeassistant-satellite/)
- [GitHub Repository](https://github.com/synesthesiam/homeassistant-satellite)
- [Issue #213 Discussion](https://github.com/rhasspy/wyoming-satellite/issues/213)
