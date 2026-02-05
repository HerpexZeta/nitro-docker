#!/bin/bash

supervisord -c /app/supervisor/supervisord.conf

# Check if Arcturus source exists
if [ -f "/app/arcturus/pom.xml" ]; then
  cd /app/arcturus
  mvn package
  cp /app/config.ini /app/arcturus/target/config.ini
  mkdir -p /app/arcturus/target/plugins
  cd /app/arcturus/target/plugins
  wget https://git.krews.org/morningstar/nitrowebsockets-for-ms/-/raw/aff34551b54527199401b343a35f16076d1befd5/target/NitroWebsockets-3.1.jar 2>/dev/null || echo "Warning: Could not download NitroWebsockets"
  supervisorctl start arcturus-emulator
else
  echo "Warning: Arcturus source not found. Emulator will not start."
  echo "To complete setup, clone Arcturus repository to emulator/arcturus"
fi

tail -f /dev/null