MYSQL_ROOT_PASSWORD=123123
mkdir -p /run/mysqld/
mariadb-install-db --datadir=./data --user=root
mariadbd --datadir=./data --user root &
sleep 5

mysqladmin -u root password  123123
