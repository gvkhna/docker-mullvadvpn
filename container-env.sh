#!/bin/bash
declare -p -x | grep -v \
  -e '^declare -x HOSTNAME=' \
  -e '^declare -x PWD=' \
  -e '^declare -x HOME=' \
  -e '^declare -x SHLVL=' \
  -e '^declare -x LC_ALL=' \
  -e '^declare -x PATH=' \
  -e '^declare -x DEBIAN_FRONTEND=' \
  -e '^declare -x _=' > /usr/local/bin/container_environment.sh
chmod 755 /usr/local/bin/container_environment.sh