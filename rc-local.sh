#!/bin/sh
# /bin/bash /root/test.sh
if [ -f /etc/custom-init.d/00-startup.sh ]; then
  echo '[custom-init] Running 00-startup.sh...'
  /bin/bash /etc/custom-init.d/00-startup.sh
fi

exit 0