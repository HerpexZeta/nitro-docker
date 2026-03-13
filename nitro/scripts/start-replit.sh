#!/bin/bash

echo "=== Starting Nitro Stack (Replit) ==="

# Start SWF HTTP server in background on port 8081
echo "Starting SWF HTTP server on port 8081..."
http-server /home/runner/workspace/nitro/nitro-swf -p 8081 --cors > /tmp/swf-server.log 2>&1 &
echo "SWF server started (PID: $!)"

# Start assets HTTP server in background on port 8080
echo "Starting assets HTTP server on port 8080..."
http-server /home/runner/workspace/nitro/nitro-assets -p 8080 --cors > /tmp/assets-server.log 2>&1 &
echo "Assets server started (PID: $!)"

# Small delay to let background servers initialize
sleep 2
echo "Background servers initialized"

# Start Nitro React dev server in foreground on port 5000
echo "Starting Nitro React dev server on port 5000..."
cd /home/runner/workspace/nitro/nitro-react
exec npm run start
