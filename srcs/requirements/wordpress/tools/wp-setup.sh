#!/bin/bash
set -e

echo "Starting WordPress setup..."

# Check if wordpress is already downloaded
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Downloading WordPress..."
    wget https://wordpress.org/latest.zip -O /tmp/wordpress.zip
    unzip /tmp/wordpress.zip -d /tmp/
    cp -r /tmp/wordpress/* /var/www/html/
    chown -R www-data:www-data /var/www/html

    echo "Creating wp-config.php..."
    cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

    sed -i "s/database_name_here/${MYSQL_DATABASE}/" /var/www/html/wp-config.php
    sed -i "s/username_here/${MYSQL_USER}/" /var/www/html/wp-config.php
    sed -i "s/password_here/${MYSQL_PASSWORD}/" /var/www/html/wp-config.php
    sed -i "s/localhost/${MYSQL_HOST}/" /var/www/html/wp-config.php
fi

echo "WordPress configuration complete."

# Start php-fpm in foreground
exec php-fpm7.4 -F
