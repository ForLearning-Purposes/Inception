FROM debian:bullseye

ARG DEBIAN_FRONTEND=noninteractive

# Install PHP + required extensions + curl + mariadb-client
RUN apt-get update && apt-get install -y \
    php-fpm \
    php-mysqli \
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

# Create directory for WordPress
RUN mkdir -p /var/www/html && chown -R www-data:www-data /var/www/html

# Copy php-fpm config
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

# Copy setup script
COPY tools/wp-setup.sh /usr/local/bin/wp-setup.sh
RUN chmod +x /usr/local/bin/wp-setup.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wp-setup.sh"]