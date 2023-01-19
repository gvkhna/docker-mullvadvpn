#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

if ! [ -e /dev/console ] ; then
  socat -u pty,link=/dev/console stdout &
fi

# save environment variables passed to container
bash /etc/container-env.sh > /dev/console 2>&1

exec /lib/systemd/systemd "$@"