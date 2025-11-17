#!/bin/bash
set -e

echo "Starting MariaDB setup..."

# Check if database is already initialized
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Start MariaDB temporarily (background)
/usr/sbin/mysqld --user=mysql --skip-networking &
sleep 5

echo "Configuring MariaDB users..."

mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

CREATE USER IF NOT EXISTS '${MYSQL_ADMIN}'@'%' IDENTIFIED BY '${MYSQL_ADMIN_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_ADMIN}'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;
EOF

# Kill temp server
killall mysqld
sleep 2

echo "Launching MariaDB..."
exec /usr/sbin/mysqld --user=mysql --datadir=/var/lib/mysql