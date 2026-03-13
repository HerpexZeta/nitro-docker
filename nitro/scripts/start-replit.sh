#!/bin/bash

set -e

WORKSPACE=/home/runner/workspace
CONFIG_SRC="$WORKSPACE/nitro/configuration/nitro-react/public/renderer-config.json"
CONFIG_DEST="$WORKSPACE/nitro/nitro-react/public/renderer-config.json"

echo "=== Starting Nitro Stack (Replit) ==="

# ── 1. Patch renderer-config.json with public Replit domain URLs ──────────────
if [ -n "$REPLIT_DEV_DOMAIN" ]; then
    echo "Patching renderer-config.json for domain: $REPLIT_DEV_DOMAIN"

    ASSET_URL="https://8080-${REPLIT_DEV_DOMAIN}"
    SWF_URL="https://8099-${REPLIT_DEV_DOMAIN}"
    SOCKET_URL="wss://3000-${REPLIT_DEV_DOMAIN}"

    cp "$CONFIG_SRC" "$CONFIG_DEST"

    # Replace localhost URLs with public Replit-proxied URLs
    sed -i "s|ws://127.0.0.1:2096|${SOCKET_URL}|g"    "$CONFIG_DEST"
    sed -i "s|http://127.0.0.1:8080|${ASSET_URL}|g"    "$CONFIG_DEST"
    sed -i "s|http://127.0.0.1:8081|${SWF_URL}|g"      "$CONFIG_DEST"

    echo "  socket.url  → ${SOCKET_URL}"
    echo "  asset.url   → ${ASSET_URL}"
    echo "  image/swf   → ${SWF_URL}"
else
    echo "REPLIT_DEV_DOMAIN not set — using config as-is"
    cp "$CONFIG_SRC" "$CONFIG_DEST"
fi

# ── 2. SWF HTTP server on port 8099 (Replit-supported, publicly proxied) ──────
echo "Starting SWF HTTP server on port 8099..."
http-server "$WORKSPACE/nitro/nitro-swf" -p 8099 --cors \
    --cache-time 3600 \
    > /tmp/swf-server.log 2>&1 &
echo "SWF server started (PID: $!)"

# ── 3. Assets HTTP server on port 8080 (Replit-supported, publicly proxied) ───
echo "Starting assets HTTP server on port 8080..."
http-server "$WORKSPACE/nitro/nitro-assets" -p 8080 --cors \
    --cache-time 3600 \
    > /tmp/assets-server.log 2>&1 &
echo "Assets server started (PID: $!)"

# ── 4. WebSocket proxy on port 3000 → Arcturus on localhost:2096 ──────────────
echo "Starting WebSocket proxy on port 3000..."
node "$WORKSPACE/nitro/scripts/ws-proxy.js" \
    > /tmp/ws-proxy.log 2>&1 &
echo "WS proxy started (PID: $!)"

# ── 5. Brief wait for background servers ──────────────────────────────────────
sleep 2
echo "Background services ready"

# ── 6. Nitro React dev server (foreground, port 5000) ─────────────────────────
echo "Starting Nitro React dev server on port 5000..."
cd "$WORKSPACE/nitro/nitro-react"
exec npm run start
