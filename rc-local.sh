#!/bin/sh

# start journalctl to follow daemon logs
journalctl -f _EXE=/usr/bin/mullvad-daemon > /dev/console &

# open any vpn input ports
bash /etc/container-input-ports.sh > /dev/console 2>&1

if [ -z $VPN_ALLOW_FORWARDING ]; then
  echo '[custom-init] Allowing Packet Forwarding...' > /dev/console
  iptables -P FORWARD ACCEPT
  iptables -t nat -A POSTROUTING -o wg+ -j MASQUERADE
fi

# run custom setup
if [ -f /etc/custom-init.d/00-startup.sh ]; then
  echo '[custom-init] Running 00-startup.sh...' > /dev/console
  /bin/bash /etc/custom-init.d/00-startup.sh
fi

exit 0