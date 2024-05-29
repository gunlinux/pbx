#!/bin/sh
/usr/sbin/asterisk_cli_server &

echo "start app"
exec "$@"
