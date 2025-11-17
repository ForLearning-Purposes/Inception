# The most stable and evaluation-friendly base image
FROM debian:bullseye

# Prevent user interaction during install
ARG DEBIAN_FRONTEND=noninteractive

# Install MariaDB
RUN apt-get update && \
    apt-get install -y mariadb-server mariadb-client && \
    rm -rf /var/lib/apt/lists/*

# Create MySQL runtime directory
# MariaDB will not start unless the mysql user can write here.
RUN mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld && \
    chmod 777 /var/run/mysqld

# Ensure datadir exists
RUN mkdir -p /var/lib/mysql && \
    chown -R mysql:mysql /var/lib/mysql

# Copy configuration
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/

# Copy entrypoint script
COPY tools/mariadb-setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb-setup.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/mariadb-setup.sh"]