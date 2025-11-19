#!/bin/bash
set -e

echo "🔧 Starting MariaDB entrypoint..."

if [ -z "${MYSQL_DATABASE}" ] || [ -z "${MYSQL_USER}" ] || [ -z "${MYSQL_PASSWORD}" ] \
 || [ -z "${MYSQL_ADMIN}" ] || [ -z "${MYSQL_ADMIN_PASSWORD}" ]; then
    echo "❌ ERROR: One or more required environment variables are missing!"
    echo "   Required: MYSQL_DATABASE, MYSQL_USER, MYSQL_PASSWORD, MYSQL_ADMIN, MYSQL_ADMIN_PASSWORD"
    exit 1
fi

# ensure we don't accidentally use TCP (unset envs that mysql client can honor)
unset MYSQL_HOST MYSQL_TCP_PORT

# explicit socket and absolute paths to binaries
SOCKET=/run/mysqld/mysqld.sock
MYSQL=/usr/bin/mysql
MYSQLADMIN=/usr/bin/mysqladmin
MYSQL_INSTALL_DB=/usr/bin/mysql_install_db
MYSQLD=/usr/sbin/mysqld

############################################
# 1. INITIAL DATABASE SETUP (FIRST RUN)
############################################
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "📦 Initializing MariaDB data directory..."
    $MYSQL_INSTALL_DB --user=mysql --datadir=/var/lib/mysql > /dev/null
fi

############################################
# 2. START TEMPORARY SERVER (SOCKET ONLY)
############################################
echo "🚀 Starting temporary MariaDB instance for configuration..."

$MYSQLD \
    --user=mysql \
    --datadir=/var/lib/mysql \
    --skip-networking \
    --socket="$SOCKET" &

TEMP_PID=$!

echo "⏳ Waiting for MariaDB to be ready..."
for i in {1..60}; do
    if $MYSQLADMIN --protocol=SOCKET -S "$SOCKET" ping >/dev/null 2>&1; then
        echo "✅ MariaDB is ready."
        break
    fi
    sleep 1
done

if ! $MYSQLADMIN --protocol=SOCKET -S "$SOCKET" ping >/dev/null 2>&1; then
    echo "❌ MariaDB failed to start during setup."
    exit 1
fi

# ...existing code...

############################################
# 3. CONFIGURE USERS & DATABASE
############################################
echo "🔐 Creating database and users..."

$MYSQL --protocol=SOCKET -u root -S "$SOCKET" <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
CREATE USER IF NOT EXISTS '${MYSQL_ADMIN}'@'%' IDENTIFIED BY '${MYSQL_ADMIN_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_ADMIN}'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

############################################
# 4. SHUT DOWN TEMPORARY SERVER
############################################
echo "🛑 Shutting down temporary MariaDB..."
$MYSQLADMIN --protocol=SOCKET -u root -S "$SOCKET" shutdown

############################################
# 5. START FULL, REAL MYSQL SERVER (PID 1)
############################################
echo "🔥 Starting MariaDB in normal mode..."
exec mysqld --user=mysql --datadir=/var/lib/mysql
#exec "$@"


# The setup script was trying to talk to MariaDB over the network, but MariaDB was only listening on a local "backdoor" (a socket), so the messages never reached it.
# I changed the script to use that local backdoor and to wait until MariaDB is ready, so the script now talks to the right place and succeeds.