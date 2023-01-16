#!/bin/sh

# start journalctl to follow mullvad-daemon logs
journalctl -f _EXE=/usr/bin/mullvad-daemon > /dev/console &

# open any vpn input ports/config
bash /etc/container-input-ports.sh > /dev/console 2>&1

# run custom init
echo '[custom-init] Looking for /etc/custom-init.d/00-startup.sh...' > /dev/console
if [ -f /etc/custom-init.d/00-startup.sh ]; then
  echo '[custom-init] Running /etc/custom-init.d/00-startup.sh...' > /dev/console
  /bin/bash /etc/custom-init.d/00-startup.sh
fi

exit 0