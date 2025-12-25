# Inception Developer Documentation

This document outlines the technical details, architecture, and development workflow for the Inception project.

---

## 🛠 Prerequisites (from scratch)

- OS: **Linux** (VM or native).
- Install required tools:
  - Docker Engine and CLI (e.g., `sudo apt install docker.io`)
  - Docker Compose plugin (`docker compose`) or `docker-compose` as required
  - `make`, `git`
- Ensure your user can run Docker (add to `docker` group):
  ```bash
  sudo usermod -aG docker $USER
  # then log out / in or restart shell
  ```

## 📂 Environment setup & secrets

1. Clone the repo and change directory:
   ```bash
   git clone <repo-url> inception && cd inception
   ```
2. Create the environment file used by Compose:
   ```bash
   cp srcs/.env.example srcs/.env  # if available
   # OR create srcs/.env manually with required vars
   ```
3. Required environment variables (example values; do not use in production):
   ```dotenv
   DOMAIN_NAME=example.com
   MYSQL_USER=wp_user
   MYSQL_DATABASE=wordpress_db
   MYSQL_PASSWORD=wp_pass
   MYSQL_ADMIN=db_admin
   MYSQL_ADMIN_PASSWORD=admin_pass
   WP_TITLE="Inception Site"
   WP_ADMIN=admin
   WP_ADMIN_PASSWORD=admin_pass
   ```
4. TLS certs: place your `server.crt` and `server.key` in `srcs/requirements/nginx/ssl/` or generate self-signed certs:
   ```bash
   openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
     -keyout srcs/requirements/nginx/ssl/server.key \
     -out srcs/requirements/nginx/ssl/server.crt -subj "/CN=${DOMAIN_NAME}" 
   ```

> Note: Keep secrets out of git (use `.gitignore`), or use a secret manager for production.

---

## 🚀 Build & Launch (Makefile + Docker Compose)

- Build and run in detached mode:
  ```bash
  make up
  # which runs: docker compose -f ./srcs/docker-compose.yml up -d --build
  ```
- Stop containers and network (does **not** remove named volumes):
  ```bash
  make down
  # which runs: docker compose -f ./srcs/docker-compose.yml down
  ```
- Stop and remove containers + prune unused Docker objects (non-destructive to volumes):
  ```bash
  make clean
  ```
- Full clean including images and unused containers:
  ```bash
  make fclean
  ```

---

## 🔎 Useful runtime commands

- See running containers: `docker compose -f srcs/docker-compose.yml ps`
- View service logs: `docker compose -f srcs/docker-compose.yml logs -f nginx`
- Exec into a container: `docker compose exec wordpress bash`
- Inspect status / health: `docker inspect -f '{{.State.Health.Status}}' <container>` (if healthcheck is configured)
- Check ports: `ss -ltnp | grep 443`

---

## 💾 Data storage & persistence

- The project uses Docker **named volumes** for persistence:
  - `srcs_mariadb_data` → mounted to `/var/lib/mysql` inside `mariadb` container
  - `srcs_wordpress_data` → mounted to `/var/www/html` inside `wordpress` container

- By default on Linux, named volumes are stored on the host under:
  ```text
  /var/lib/docker/volumes/<volume_name>/_data
  ```
  Example verification:
  ```bash
  docker volume ls
  docker volume inspect srcs_mariadb_data --format '{{ .Mountpoint }}'
  ```

- Important persistence rules:
  - Removing containers or images alone does **not** delete named volumes.
  - To remove volumes explicitly: `docker compose down -v` or `docker volume rm <volume>` (destructive).
  - Bind mounts (host directories) are never removed by Docker.

---

## 🗂 Making volumes available under /home/msimic/data

If you need your volumes accessible under `/home/<your-login>/data` (host), two safe options:

A) Convert to bind mounts (recommended):
1. Stop stack: `docker compose -f srcs/docker-compose.yml down`
2. Create host dirs:
   ```bash
   mkdir -p /home/<login>/data/mariadb /home/<login>/data/wordpress
   ```
3. Copy existing volume contents into host dirs:
   ```bash
   docker run --rm -v srcs_mariadb_data:/from -v /home/<login>/data/mariadb:/to busybox sh -c "cp -a /from/. /to/"
   docker run --rm -v srcs_wordpress_data:/from -v /home/<login>/data/wordpress:/to busybox sh -c "cp -a /from/. /to/"
   ```
4. Update `docker-compose.yml` to bind mount the host directories:
   ```yaml
   services:
     mariadb:
       volumes:
         - /home/<login>/data/mariadb:/var/lib/mysql
     wordpress:
       volumes:
         - /home/<login>/data/wordpress:/var/www/html
   ```
5. Start stack and fix ownership if needed:
   ```bash
   docker compose -f srcs/docker-compose.yml up -d
   docker compose exec mariadb chown -R mysql:mysql /var/lib/mysql
   docker compose exec wordpress chown -R www-data:www-data /var/www/html
   ```

B) Keep named volumes but bind them to host directories (local driver):
- Edit the top-level `volumes:` in `docker-compose.yml` to use `driver_opts` and `device: /home/<login>/data/...`.

---

## 🛡 Backups & safe operations

- Backup a named volume to host:
  ```bash
  docker run --rm -v srcs_mariadb_data:/from -v /home/<login>/backup:/to busybox sh -c "cd /from && tar -czf /to/mariadb_$(date +%F).tgz ."
  ```
- Restore by extracting into the host dir or a temporary container and reattaching.
- Always stop database containers before copying DB files to avoid corruption.

---

## ✅ Quick verification checklist

- Stack running: `docker compose -f srcs/docker-compose.yml ps`
- WP core present: `docker compose exec wordpress test -f /var/www/html/wp-includes/version.php && echo OK`
- DB accessible: `docker compose exec mariadb mysql -u${MYSQL_ADMIN} -p${MYSQL_ADMIN_PASSWORD} -e "SHOW DATABASES;"`
- Volumes exist: `docker volume ls | grep srcs_`
- Network exists: `docker network ls | grep inception`

---

## Notes

- Keep secrets out of VCS. Use `.env` ignored by git or a secret store for production.  
- If you need, I can add a `docs/quick-check.sh` script that runs the verification commands above automatically.

---

*Last updated: 2025-12-25*
