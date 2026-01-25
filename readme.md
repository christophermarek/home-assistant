https://www.home-assistant.io/

start services

```bash
make start
```

stop services

```bash
make stop
```

view status

```bash
make status
```

view logs

```bash
make logs
```

After starting the services, add Whisper, Piper, and Wake Word in Home Assistant:
1. Go to Settings > Devices & Services > Add Integration
2. Search for "Wyoming Protocol"
3. Add Whisper: Host = `whisper`, Port = `10300`
4. Add Piper: Host = `piper`, Port = `10200`
5. Add Wake Word: Host = `wake-word`, Port = `10400`
6. Configure your Assist pipeline to use:
   - Wake Word: Open Wake Word (optional, for hands-free activation with "Ok Nabu")
   - Speech-to-Text: Whisper
   - Text-to-Speech: Piper

Note: Use the service names (`whisper`, `piper`, `wake-word`) as hostnames, not `localhost`, since all services run in Docker containers on the same network.

**Microphone Input:**
For Docker-based Home Assistant, microphone input is handled by the client (browser or mobile app), not a separate service. The `assist_microphone` addon is only available for HassIO/Home Assistant OS. To use voice commands:
- **Mobile App**: Use the Home Assistant mobile app which has built-in microphone support
- **Web Browser**: Grant microphone permissions when using Assist in the browser
- **Wake Word**: The wake word service enables hands-free activation - say "Ok Nabu" to start voice commands

**ESPHome Device Builder:**
Access the ESPHome Device Builder (dashboard) at http://localhost:6052 to create and manage your ESP device configurations. ESPHome configurations are stored in `./config/esphome/`. USB flashing is supported on Ubuntu - connect your ESP device via USB and it will be available in the dashboard for initial flashing. After the initial USB flash, you can use over-the-air updates for all subsequent updates.

**Adding ESPHome Devices to Home Assistant:**
After flashing your ESP device with ESPHome firmware, add it to Home Assistant:

1. **Automatic Discovery (recommended):**
   - ESPHome devices are automatically discovered via mDNS
   - Go to Settings > Devices & Services
   - Look for discovered ESPHome devices (may take up to 5 minutes)
   - Click "CONFIGURE" on the discovered device to add it

2. **Manual Addition:**
   - If auto-discovery doesn't work, manually add the device:
   - Go to Settings > Devices & Services > Add Integration
   - Search for "ESPHome"
   - Enter your device's hostname (e.g., `livingroom.local`) or IP address
   - Enter the encryption key if you set one in your ESPHome configuration

Once added, all entities (sensors, switches, lights, etc.) from your ESPHome device will automatically appear in Home Assistant.

**Scrypted NVR:**
Access Scrypted at https://localhost:10443 to configure cameras and NVR functionality. Scrypted provides camera integration with HomeKit, Google Home, Alexa, and Home Assistant. To integrate Scrypted with Home Assistant:

1. Go to Settings > Devices & Services > Add Integration
2. Search for "Scrypted"
3. Enter the Scrypted server URL (e.g., `http://localhost:10444` for HTTP or `https://localhost:10443` for HTTPS)
4. Follow the setup wizard to complete the integration

Scrypted data is stored in `./data/scrypted/`. For NVR storage, configure the `SCRYPTED_NVR_VOLUME` environment variable in your Makefile or docker-compose.yml.
