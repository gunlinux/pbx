#!/bin/bash
export DB_HOST=${MARIADB_HOST}
export DB_USER="root"
export DB_PORT=${MARIADB_PORT}
export DB_PASSWORD=${MARIADB_ROOT_PASSWORD}

echo 'Waiting database to start...'

while ! nc -z $DB_HOST $DB_PORT; do
    sleep 5
done

echo 'Database started'

echo  ${MARIADB_USER}


database_exists() {
    local database_name="$1"
    local output=$(mysql -u "$DB_USER" -h ${DB_HOST} -p"${DB_PASSWORD}" -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$database_name'")
    if [ -z "$output" ]; then
        echo "false"
    else
        echo "true"
    fi
}

# Check if the 'asterisk' database exists
if [ "$(database_exists 'asterisk')" == "false" ]; then
    echo "Database 'asterisk' does not exist. Loading dump..."
    echo "connection ${DB_HOST} ${DB_USER} ${DB_PASSWORD}"
    # Load the database dump
    mysql -h ${DB_HOST} -u "$DB_USER" -p"${DB_PASSWORD}" -e "CREATE DATABASE asterisk;" 
    mysql -h ${DB_HOST} -u "$DB_USER" -p"${DB_PASSWORD}" asterisk < /opt/dump.sql

    echo "Database dump loaded successfully."
else
    echo "Database 'asterisk' already exists. Skipping dump load."
fi



echo "start app"
exec "$@"
