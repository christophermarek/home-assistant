.PHONY: start stop status logs

HA_HOST ?=
HA_TOKEN ?=
VENV_DIR ?= .venv

start:
ifeq ($(OS),Windows_NT)
ifeq ($(HA_HOST),)
	@echo ERROR: HA_HOST required
	@echo Usage: start.bat HA_HOST HA_TOKEN
	@exit /b 1
endif
ifeq ($(HA_TOKEN),)
	@echo ERROR: HA_TOKEN required
	@exit /b 1
endif
	@ffmpeg -version >nul 2>&1 || (echo ERROR: FFmpeg not installed && exit /b 1)
	@python --version || (echo ERROR: Python not installed && exit /b 1)
	@if not exist "$(VENV_DIR)" python -m venv $(VENV_DIR)
	@$(VENV_DIR)\Scripts\pip install --quiet --upgrade pip
	@$(VENV_DIR)\Scripts\pip install --quiet sounddevice homeassistant-satellite
	@echo Starting satellite to $(HA_HOST)...
	@$(VENV_DIR)\Scripts\python -m homeassistant_satellite --host $(HA_HOST) --token $(HA_TOKEN)
else
	@echo Use start.bat on Windows
	@echo This Makefile is for Windows only
endif

stop:
	@echo Press Ctrl+C in the terminal where satellite is running

status:
	@echo Check the terminal where satellite is running

logs:
	@echo Logs display in the terminal running start
