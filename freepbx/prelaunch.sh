#!/bin/bash
DB_HOST=${MARIADB_HOST}
DB_USER="root"
DB_PORT=${MARIADB_PORT}
DB_PASSWORD=${MARIADB_ROOT_PASSWORD}
FILE_PATH="/etc/freepbx.conf"

sed -i "s/^\(\$amp_conf\['AMPDBUSER'\] = \).*/\1'$DB_USER';/" $FILE_PATH
# Update the AMPDBPASS
sed -i "s/^\(\$amp_conf\['AMPDBPASS'\] = \).*/\1'$DB_PASSWORD';/" $FILE_PATH
# Update the AMPDBHOST
sed -i "s/^\(\$amp_conf\['AMPDBHOST'\] = \).*/\1'$DB_HOST';/" $FILE_PATH


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
if [ "$(database_exists 'asteriskcdrdb')" == "false" ]; then
    echo "Database 'asterisk' does not exist. Loading dump..."
    echo "connection ${DB_HOST} ${DB_USER} ${DB_PASSWORD}"
    # Load the database dump
    mysql -h ${DB_HOST} -u "$DB_USER" -p"${DB_PASSWORD}" -e "CREATE DATABASE asterisk;" 
    mysql -h ${DB_HOST} -u "$DB_USER" -p"${DB_PASSWORD}" -e "CREATE DATABASE asteriskcdrdb;" 
    mysql -h ${DB_HOST} -u "$DB_USER" -p"${DB_PASSWORD}" asterisk < /opt/dump.sql
    mysql -h ${DB_HOST} -u "$DB_USER" -p"${DB_PASSWORD}" asteriskcdrdb < /opt/dumpcdr.sql

    echo "Database dump loaded successfully."
else
    echo "Database 'asterisk' already exists. Skipping dump load."
fi



echo "start app"
exec "$@"
