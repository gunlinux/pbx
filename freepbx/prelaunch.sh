#!/bin/bash
export DB_HOST=db
export DB_PORT=3306

echo 'Waiting database to start...'

while ! nc -z $DB_HOST $DB_PORT; do
    sleep 5
done

echo 'Database started'

echo  ${MARIADB_USER}


database_exists() {
    local database_name="$1"
    local output=$(mysql -u "$DB_USER" -h db -p"${DB_PASSWORD}" -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$database_name'")
    if [ -z "$output" ]; then
        echo "false"
    else
        echo "true"
    fi
}

# Check if the 'asterisk' database exists
if [ "$(database_exists 'asterisk')" == "false" ]; then
    echo "Database 'asterisk' does not exist. Loading dump..."

    # Load the database dump
    mysql -h db -u "$DB_USER" -p"${DB_PASSWORD}" < /opt/dump.sql

    echo "Database dump loaded successfully."
else
    echo "Database 'asterisk' already exists. Skipping dump load."
fi



echo "start app"
exec "$@"
