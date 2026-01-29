.PHONY: setup start stop status

RTSP_PORT ?= 8554
BIN_DIR ?= bin
FFMPEG_EXE ?= $(BIN_DIR)/ffmpeg.exe

setup:
	@powershell -ExecutionPolicy Bypass -File setup.ps1

start:
	@powershell -ExecutionPolicy Bypass -File start.ps1 -Port $(RTSP_PORT)

stop:
	@powershell -ExecutionPolicy Bypass -File stop.ps1

status:
	@powershell -ExecutionPolicy Bypass -File status.ps1
