@echo off
setlocal enabledelayedexpansion

echo Home Assistant Satellite for Windows
echo =====================================
echo.

set VENV_DIR=.venv
set HA_HOST=
set HA_TOKEN=

if not "%~1"=="" set HA_HOST=%~1
if not "%~2"=="" set HA_TOKEN=%~2

if "%HA_HOST%"=="" (
    echo ERROR: Home Assistant host is required
    echo.
    echo Usage: start.bat ^<HA_HOST^> ^<HA_TOKEN^>
    echo Example: start.bat 192.168.1.100 your_long_lived_token
    echo.
    echo To create a long-lived access token:
    echo 1. Go to Home Assistant ^> Profile
    echo 2. Scroll to "Long-lived access tokens"
    echo 3. Click "Create token"
    echo.
    pause
    exit /b 1
)

if "%HA_TOKEN%"=="" (
    echo ERROR: Home Assistant token is required
    echo.
    echo Usage: start.bat ^<HA_HOST^> ^<HA_TOKEN^>
    echo.
    pause
    exit /b 1
)

echo Checking Python installation...
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed.
    echo Please install Python 3.9+ from https://python.org
    echo Make sure to check "Add Python to PATH" during installation
    pause
    exit /b 1
)

echo Checking FFmpeg installation...
ffmpeg -version >nul 2>&1
if errorlevel 1 (
    echo WARNING: FFmpeg is not installed or not in PATH.
    echo.
    echo To install FFmpeg:
    echo 1. Download from https://ffmpeg.org/download.html
    echo 2. Extract and add bin folder to PATH
    echo.
    echo Or use winget: winget install ffmpeg
    echo Or use choco: choco install ffmpeg
    echo.
    pause
    exit /b 1
)

if not exist "%VENV_DIR%" (
    echo Creating virtual environment...
    python -m venv %VENV_DIR%
)

echo Activating virtual environment...
call %VENV_DIR%\Scripts\activate.bat

echo Installing dependencies...
pip install --quiet --upgrade pip
pip install --quiet sounddevice
pip install --quiet homeassistant-satellite

echo.
echo Starting Home Assistant Satellite...
echo Host: %HA_HOST%
echo.
echo Press Ctrl+C to stop
echo.

python -m homeassistant_satellite --host %HA_HOST% --token %HA_TOKEN%

pause
