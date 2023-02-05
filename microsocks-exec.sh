#!/bin/bash

source /usr/local/etc/container_environment

echo "[microsocks] MICROSOCKS_ENABLE=${MICROSOCKS_ENABLE}" > /dev/console

echo "[microsocks] Starting microsocks..." > /dev/console

BIND_ADDR="${MICROSOCKS_BIND_ADDR:-0.0.0.0}"
PORT="${MICROSOCKS_PORT:-9118}"

if [[ "${MICROSOCKS_AUTH_NONE}" == "true" ]]; then
    if [[ "${DEBUG}" == "true" ]]; then
        echo "[microsocks][no-auth] bind: '$BIND_ADDR' port: '$PORT'" > /dev/console
    fi

    exec /usr/bin/microsocks -i $BIND_ADDR -p $PORT
else
    USER="${MICROSOCKS_USER:-admin}"
    PASS="${MICROSOCKS_PASS:-socks}"

    if [[ "${DEBUG}" == "true" ]]; then
        echo "[microsocks][auth] bind: '$BIND_ADDR' port: '$PORT' user: '$USER' pass: '$PASS'" > /dev/console
    fi

    exec /usr/bin/microsocks -i $BIND_ADDR -p $PORT -u $USER -P $PASS
fi
