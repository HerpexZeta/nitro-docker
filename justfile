set windows-powershell := true

default:
  @just --list

# Install all easily
install:
  git submodule init
  git submodule update

# Start asset server, swf server & Nitro dev server (Replit)
start-all:
  bash nitro/scripts/start-replit.sh

# Extract nitro assets from SWF (Replit, no Docker)
extract-nitro-assets:
  bash nitro/scripts/extract-assets.sh

# Restart Nitro dev server
restart-nitro:
  cp nitro/configuration/nitro-react/public/* nitro/nitro-react/public/
  pkill -f "vite" || true
  cd nitro/nitro-react && npm run start

# Kill all background servers
stop-all:
  pkill -f "http-server" || true
  pkill -f "vite" || true
  @echo "All servers stopped"
