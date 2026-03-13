#!/bin/bash
set -e

echo "=== Nitro Asset Extraction ==="

WORKSPACE=/home/runner/workspace

# Copy converter config (points to port 8081 SWF server)
echo "Copying converter config..."
cp "$WORKSPACE/nitro/configuration/nitro-converter/configuration.json" \
   "$WORKSPACE/nitro/nitro-converter/configuration.json"

# Check if SWF server is already running on port 8081
SWF_STARTED=false
if curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8081/gamedata/furnidata.xml | grep -q "200"; then
    echo "SWF server already running on port 8081, using it..."
else
    echo "Starting SWF HTTP server on port 8081..."
    http-server "$WORKSPACE/nitro/nitro-swf" -p 8081 --cors > /tmp/swf-server-extract.log 2>&1 &
    SWF_PID=$!
    SWF_STARTED=true
    echo "SWF server started (PID: $SWF_PID)"

    echo "Waiting for SWF server..."
    for i in $(seq 1 20); do
        if curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8081/gamedata/furnidata.xml | grep -q "200"; then
            echo "SWF server ready!"
            break
        fi
        echo "Attempt $i/20: waiting 2s..."
        sleep 2
    done
fi

# Run the converter
echo "Running nitro-converter (converting 2000+ SWF files, this will take a while)..."
cd "$WORKSPACE/nitro/nitro-converter"
npx ts-node-dev --transpile-only src/Main.ts

# Move assets to nitro-assets directory
echo "Moving converted assets to nitro-assets..."
if command -v rsync &> /dev/null; then
    rsync -r "$WORKSPACE/nitro/nitro-converter/assets/" "$WORKSPACE/nitro/nitro-assets/"
else
    cp -r "$WORKSPACE/nitro/nitro-converter/assets/." "$WORKSPACE/nitro/nitro-assets/"
fi

# Stop the SWF server if we started it
if [ "$SWF_STARTED" = true ]; then
    echo "Stopping temporary SWF server (PID: $SWF_PID)..."
    kill $SWF_PID 2>/dev/null || true
fi

echo "=== Asset extraction complete! Run 'just start-all' to start all servers ==="
