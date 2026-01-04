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

After starting the services, add Whisper and Piper in Home Assistant:
1. Go to Settings > Devices & Services > Add Integration
2. Search for "Wyoming Protocol"
3. Add Whisper: Host = localhost, Port = 10300
4. Add Piper: Host = localhost, Port = 10200
5. Configure your Assist pipeline to use Whisper for Speech-to-Text and Piper for Text-to-Speech
