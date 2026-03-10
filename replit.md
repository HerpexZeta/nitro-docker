# Nitro Docker - Replit Setup

## Project Overview
This is a Habbo Hotel emulator development environment called "Nitro Docker". It consists of:

1. **nitro-react** (frontend) - React-based Habbo client (Nitro 2.2.0), served on port 5000
2. **Arcturus Emulator** (backend, not running in Replit) - Java-based hotel emulator (WebSocket on port 2096)
3. **MySQL** (database, not running in Replit) - MariaDB for game data
4. **Asset servers** (not running in Replit) - HTTP servers for game assets/SWF files on ports 8080 and 8081

## What's Running in Replit
Only the **nitro-react frontend** is set up to run in Replit (the other components require Docker).

- Workflow: "Start application" → `cd nitro/nitro-react && npm run start`
- Port: 5000
- The frontend connects to backend services via config in `nitro/nitro-react/public/`

## Project Structure
```
nitro/
  nitro-react/         # React frontend (cloned from billsonnn/nitro-react)
  configuration/
    nitro-react/
      public/          # Config files (renderer-config.json, ui-config.json)
  nitro-assets/        # Game assets (submodule, not populated)
  nitro-converter/     # Asset converter tool (submodule, not populated)
  nitro-swf/           # SWF files (submodule, not populated)
emulator/
  arcturus/            # Java emulator (submodule, not populated)
  config.ini           # Emulator configuration
mysql/
  dumps/               # Database SQL dumps
```

## Original Docker Setup
In the full Docker environment, all services run together:
- MySQL on port 13306 (host) / 3306 (container)
- Arcturus emulator on ports 3000, 3001, 2096
- Nitro assets server on port 8080
- Nitro SWF server on port 8081
- Nitro dev server on port 1080 (mapped from 5154)

## Key Configuration
- Backend WebSocket: `ws://127.0.0.1:2096` (configurable in renderer-config.json)
- Asset URL: `http://127.0.0.1:8080` (configurable in renderer-config.json)
- Game config files: `nitro/nitro-react/public/renderer-config.json` and `ui-config.json`

## Notes
- The app shows a black screen in Replit because the Arcturus backend and asset servers are not running
- To run the full stack, use Docker with `just install && just start-all`
- The nitro-react submodule was cloned directly since git submodule operations are restricted in Replit
