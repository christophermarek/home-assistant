# Wyoming Satellite for Windows

Voice satellite for Home Assistant using [wyoming-satellite](https://github.com/rhasspy/wyoming-satellite) via WSL.

## Requirements

- Windows 10/11
- Home Assistant with Assist pipeline configured (Whisper + Piper)

## Quick Start

### 1. Install

Open PowerShell as Administrator and run:

```powershell
.\setup.ps1
```

This will:
- Install WSL and Ubuntu (requires restart)
- Install all dependencies
- Clone and set up wyoming-satellite

### 2. Start

```powershell
.\start.ps1
```

### 3. Connect to Home Assistant

1. Go to **Settings** → **Devices & Services**
2. Click **Add Integration**
3. Search for **Wyoming Protocol**
4. Enter the Host and Port shown in the terminal

## Commands

Start satellite:
```powershell
.\start.ps1
```

Start with custom name:
```powershell
.\start.ps1 -Name "Office Satellite"
```

Start on different port:
```powershell
.\start.ps1 -Port 10701
```

Stop satellite:
Press `Ctrl+C` in the terminal

## Manual Setup

If you prefer to set things up manually:

### Install WSL

```powershell
wsl --install -d Ubuntu
```

Restart, then open Ubuntu and create a username/password.

### Install Dependencies

```bash
sudo apt update
sudo apt install -y python3 python3-pip python3-venv ffmpeg git alsa-utils
```

### Clone and Install

```bash
cd ~
git clone https://github.com/rhasspy/wyoming-satellite.git
cd wyoming-satellite
python3 -m venv .venv
source .venv/bin/activate
pip install -e .
```

### Run

```bash
python -m wyoming_satellite \
  --name "Windows Satellite" \
  --uri tcp://0.0.0.0:10700 \
  --mic-command "parec --rate=16000 --channels=1 --format=s16le --raw" \
  --snd-command "paplay --rate=22050 --channels=1 --format=s16le --raw"
```

## Troubleshooting

### No audio

Check PulseAudio sources:
```bash
wsl -d Ubuntu -- pactl list sources short
wsl -d Ubuntu -- pactl list sinks short
```

### Test microphone

```bash
wsl -d Ubuntu -- bash -c "parec --rate=16000 --channels=1 --format=s16le --raw | head -c 32000 > /tmp/test.raw && paplay --rate=16000 --channels=1 --format=s16le --raw /tmp/test.raw"
```

### Connection refused

Make sure Windows Firewall allows port 10700:
1. Open Windows Defender Firewall
2. Advanced Settings → Inbound Rules
3. New Rule → Port → TCP 10700 → Allow

### Reset installation

```powershell
wsl --unregister Ubuntu
.\setup.ps1
```

## Alternative

For a GUI app instead of command line:
[Home Assistant Assist Desktop](https://github.com/home-assistant/assist-desktop/releases)

## References

- [Wyoming Satellite](https://github.com/rhasspy/wyoming-satellite)
- [Wyoming Protocol](https://github.com/rhasspy/wyoming)
- [Home Assistant Voice](https://www.home-assistant.io/voice_control/)
