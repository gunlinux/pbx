#!/bin/bash
export DB_HOST=db
export DB_PORT=3306

echo 'Waiting database to start...'

while ! nc -z $DB_HOST $DB_PORT; do
    sleep 5
done

echo 'Database started'

echo  ${MARIADB_USER}

echo "start app"
exec "$@"
