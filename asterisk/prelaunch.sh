#!/bin/sh
starting asterisk clie
/usr/sbin/asterisk_cli_server &

echo "start app"
exec "$@"
