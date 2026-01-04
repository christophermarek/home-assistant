.PHONY: start stop status logs

HA_IMAGE ?= ghcr.io/home-assistant/home-assistant:stable
HA_CONTAINER_NAME ?= homeassistant
CONFIG_DIR ?= $(shell pwd)/config
HA_PORT ?= 8123
TZ ?= America/New_York

WHISPER_IMAGE ?= rhasspy/wyoming-whisper:latest
WHISPER_CONTAINER_NAME ?= whisper
WHISPER_MODEL ?= tiny-int8
WHISPER_LANGUAGE ?= en
WHISPER_PORT ?= 10300
WHISPER_DATA_DIR ?= $(shell pwd)/data/whisper

PIPER_IMAGE ?= rhasspy/wyoming-piper:latest
PIPER_CONTAINER_NAME ?= piper
PIPER_VOICE ?= en_US-lessac-medium
PIPER_PORT ?= 10200
PIPER_DATA_DIR ?= $(shell pwd)/data/piper

export HA_IMAGE HA_CONTAINER_NAME CONFIG_DIR HA_PORT TZ
export WHISPER_IMAGE WHISPER_CONTAINER_NAME WHISPER_MODEL WHISPER_LANGUAGE WHISPER_PORT WHISPER_DATA_DIR
export PIPER_IMAGE PIPER_CONTAINER_NAME PIPER_VOICE PIPER_PORT PIPER_DATA_DIR

start:
	@mkdir -p $(CONFIG_DIR) $(WHISPER_DATA_DIR) $(PIPER_DATA_DIR)
	@docker-compose up -d
	@echo "Services started!"
	@echo "Home Assistant: http://localhost:$(HA_PORT)"
	@echo "Whisper: http://localhost:$(WHISPER_PORT)"
	@echo "Piper: http://localhost:$(PIPER_PORT)"

stop:
	@docker-compose down
	@echo "Services stopped"

status:
	@docker-compose ps

logs:
	@docker-compose logs -f