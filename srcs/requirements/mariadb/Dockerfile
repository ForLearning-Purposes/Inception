# Correct Debian base image (stable Debian 12)
FROM debian:bookworm

# Prevent interactive prompts during installations
ARG DEBIAN_FRONTEND=noninteractive

# Install MariaDB server + client
RUN apt-get update && \
    apt-get install -y mariadb-server mariadb-client && \
    rm -rf /var/lib/apt/lists/*

# Create required MariaDB runtime directory
# MariaDB will NOT start without this directory existing and writable.
RUN mkdir -p /run/mysqld && \
    chown -R mysql:mysql /run/mysqld && \
    chmod 777 /run/mysqld

# Prepare MariaDB data directory (bind-mounted volume)
RUN mkdir -p /var/lib/mysql /run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql && \
    chown -R mysql:mysql /run/mysqld

# Copy MariaDB configuration
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/

# Copy entrypoint script
COPY tools/mariadb-setup.sh /usr/local/bin/mariadb-setup.sh
RUN chmod +x /usr/local/bin/mariadb-setup.sh

# No port exposure needed, NGINX is the only public entry point.
# EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/mariadb-setup.sh"]

#CMD ["mysqld", "--user=mysql", "--datadir=/var/lib/mysql"]