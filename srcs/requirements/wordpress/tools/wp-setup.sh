#!/bin/bash
set -e

echo "🚀 Starting WordPress setup..."

WP_PATH="/var/www/html"

############################################
# 1. DOWNLOAD WORDPRESS IF NOT INSTALLED
############################################
if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo "📦 Downloading WordPress..."
    wget -q https://wordpress.org/latest.zip -O /tmp/wordpress.zip
    unzip -q /tmp/wordpress.zip -d /tmp/

    echo "📁 Installing WordPress..."
    cp -r /tmp/wordpress/* "$WP_PATH"
    rm -rf /tmp/wordpress /tmp/wordpress.zip

    echo "📝 Creating wp-config.php..."
    cp "$WP_PATH/wp-config-sample.php" "$WP_PATH/wp-config.php"

    sed -i "s/database_name_here/${MYSQL_DATABASE}/" "$WP_PATH/wp-config.php"
    sed -i "s/username_here/${MYSQL_USER}/" "$WP_PATH/wp-config.php"
    sed -i "s/password_here/${MYSQL_PASSWORD}/" "$WP_PATH/wp-config.php"
    sed -i "s/localhost/${MYSQL_HOST}/" "$WP_PATH/wp-config.php"

    echo "🔐 Generating WordPress security salts..."
    SALTS=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
    sed -i "/AUTH_KEY/d" "$WP_PATH/wp-config.php"
    sed -i "/SECURE_AUTH_KEY/d" "$WP_PATH/wp-config.php"
    sed -i "/LOGGED_IN_KEY/d" "$WP_PATH/wp-config.php"
    sed -i "/NONCE_KEY/d" "$WP_PATH/wp-config.php"
    sed -i "/AUTH_SALT/d" "$WP_PATH/wp-config.php"
    sed -i "/SECURE_AUTH_SALT/d" "$WP_PATH/wp-config.php"
    sed -i "/LOGGED_IN_SALT/d" "$WP_PATH/wp-config.php"
    sed -i "/NONCE_SALT/d" "$WP_PATH/wp-config.php"

    echo "$SALTS" >> "$WP_PATH/wp-config.php"

    echo "🔧 Fixing permissions..."
    chown -R www-data:www-data "$WP_PATH"
fi

echo "✅ WordPress setup complete."

############################################
# 4. START PHP-FPM AS PID 1
############################################
echo "🚀 Starting php-fpm..."
exec php-fpm8.2 -F
