#!/bin/bash
set -e

echo "🚀 Starting WordPress setup..."

WP_PATH="/var/www/html"
mkdir -p "$WP_PATH"

# Make sure WordPress core exists before any wp-cli calls
if [ ! -f "$WP_PATH/wp-includes/version.php" ]; then
  echo "[wordpress] Downloading WordPress core..."
  wp core download \
    --allow-root \
    --path="$WP_PATH" \
    --locale="${WP_LOCALE:-en_US}" \
    --force
fi

# Wait for DB to be reachable
echo "[wordpress] Waiting for MariaDB..."
until mysqladmin ping -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent; do
  sleep 1
done
echo "[wordpress] MariaDB is ready."

cd "$WP_PATH"

# Create wp-config.php if missing
if [ ! -f wp-config.php ]; then
  wp config create \
    --dbname="${MYSQL_DATABASE}" \
    --dbuser="${MYSQL_USER}" \
    --dbpass="${MYSQL_PASSWORD}" \
    --dbhost="${MYSQL_HOST}" \
    --skip-check \
    --allow-root
fi

# Install WordPress if not installed yet
if ! wp core is-installed --allow-root; then
  echo "[wordpress] Installing WordPress..."

  wp core install \
    --url="https://${DOMAIN_NAME}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email \
    --allow-root

  # Create regular user if it does not already exist
  if [ -n "${WP_USER:-}" ] && ! wp user get "${WP_USER}" --allow-root >/dev/null 2>&1; then
    wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
      --user_pass="${WP_USER_PASSWORD}" \
      --role=author \
      --allow-root
  fi

  # Install and activate locale/language if provided
  if [ -n "${WP_LOCALE:-}" ]; then
    wp language core install "${WP_LOCALE}" --activate --allow-root || true
  fi

  echo "[wordpress] WordPress installed + users created."
fi

chown -R www-data:www-data "$WP_PATH"

echo "✅ WordPress setup complete."

echo "🚀 Starting php-fpm..."
exec php-fpm8.2 -F
