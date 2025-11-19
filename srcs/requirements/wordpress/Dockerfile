FROM debian:bookworm

ARG DEBIAN_FRONTEND=noninteractive

# Install PHP 8.2 + extensions + mariadb client
RUN apt-get update && apt-get install -y \
    php-fpm \
    php-mysql \
    php-curl \
    php-gd \
    php-mbstring \
    php-xml \
    php-zip \
    php-opcache \
    php-intl \
    mariadb-client \
    curl \
    wget \
    unzip && \
    rm -rf /var/lib/apt/lists/*

# Create PHP-FPM runtime directory (required for PID + socket)
RUN mkdir -p /run/php && chown -R www-data:www-data /run/php

# Create WordPress working directory
RUN mkdir -p /var/www/html && chown -R www-data:www-data /var/www/html

# Copy php-fpm pool configuration for WordPress
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# Copy WordPress setup script
COPY tools/wp-setup.sh /usr/local/bin/wp-setup.sh
RUN chmod +x /usr/local/bin/wp-setup.sh

ENTRYPOINT ["/usr/local/bin/wp-setup.sh"]
