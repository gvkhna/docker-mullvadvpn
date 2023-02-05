#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# link container stdout to /dev/console
if ! [ -e /dev/console ] ; then
  socat -u pty,link=/dev/console stdout &
fi

sh -c "set" | grep \
  -e 'MICROSOCKS_ENABLE=' \
  -e 'VPN_INPUT_PORTS=' \
  -e 'VPN_ALLOW_FORWARDING=' \
  -e 'MICROSOCKS_BIND_ADDR=' \
  -e 'MICROSOCKS_PORT=' \
  -e 'MICROSOCKS_USER=' \
  -e 'MICROSOCKS_PASS=' \
  -e 'MICROSOCKS_AUTH_NONE=' \
  -e 'TINYPROXY_ENABLE=' \
  -e 'DEBUG=' \
   > /usr/local/etc/container_environment

exec /lib/systemd/systemd "$@"