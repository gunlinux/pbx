MYSQL_ROOT_PASSWORD=123123

mkdir -p /run/mysqld
mariadbd --user root  &
sleep 15 
mysql_secure_installation <<EOF

y
$MYSQL_ROOT_PASSWORD
$MYSQL_ROOT_PASSWORD
y
y
y
y
EOF

