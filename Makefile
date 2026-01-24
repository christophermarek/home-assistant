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

WAKE_WORD_IMAGE ?= rhasspy/wyoming-openwakeword:latest
WAKE_WORD_CONTAINER_NAME ?= wake-word
WAKE_WORD_MODEL ?= ok_nabu
WAKE_WORD_PORT ?= 10400
WAKE_WORD_DATA_DIR ?= $(shell pwd)/data/wake-word

ESPHOME_IMAGE ?= ghcr.io/esphome/esphome:stable
ESPHOME_CONTAINER_NAME ?= esphome
ESPHOME_PORT ?= 6052
ESPHOME_CONFIG_DIR ?= $(shell pwd)/config/esphome
ESPHOME_USERNAME ?=
ESPHOME_PASSWORD ?=

export HA_IMAGE HA_CONTAINER_NAME CONFIG_DIR HA_PORT TZ
export WHISPER_IMAGE WHISPER_CONTAINER_NAME WHISPER_MODEL WHISPER_LANGUAGE WHISPER_PORT WHISPER_DATA_DIR
export PIPER_IMAGE PIPER_CONTAINER_NAME PIPER_VOICE PIPER_PORT PIPER_DATA_DIR
export WAKE_WORD_IMAGE WAKE_WORD_CONTAINER_NAME WAKE_WORD_MODEL WAKE_WORD_PORT WAKE_WORD_DATA_DIR
export ESPHOME_IMAGE ESPHOME_CONTAINER_NAME ESPHOME_PORT ESPHOME_CONFIG_DIR ESPHOME_USERNAME ESPHOME_PASSWORD

start:
	@mkdir -p $(CONFIG_DIR) $(WHISPER_DATA_DIR) $(PIPER_DATA_DIR) $(WAKE_WORD_DATA_DIR) $(ESPHOME_CONFIG_DIR)
	@docker-compose up -d
	@echo "Services started!"
	@echo "Home Assistant: http://localhost:$(HA_PORT)"
	@echo "Whisper: http://localhost:$(WHISPER_PORT)"
	@echo "Piper: http://localhost:$(PIPER_PORT)"
	@echo "Wake Word: http://localhost:$(WAKE_WORD_PORT)"
	@echo "ESPHome: http://localhost:$(ESPHOME_PORT)"

stop:
	@docker-compose down
	@echo "Services stopped"

status:
	@docker-compose ps

logs:
	@docker-compose logs -f