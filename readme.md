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
