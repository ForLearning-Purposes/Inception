# Inception User Guide

This document explains in simple terms how to use and administer the Inception stack (NGINX, WordPress, MariaDB).

---

## 🧩 Services provided

- **NGINX (reverse proxy & TLS terminator):** Public entry point, serves static files and forwards PHP requests to WordPress (PHP‑FPM). Listens on port **443** (HTTPS).
- **WordPress (PHP‑FPM):** The web application that serves the site and admin UI (`/wp-admin`). Runs PHP‑FPM and stores site files at `/var/www/html` (volume: `srcs_wordpress_data`).
- **MariaDB (database):** Stores WordPress data (database, users, options) at `/var/lib/mysql` (volume: `srcs_mariadb_data`).

---

## 🚀 Start and stop the project

Use the `Makefile` at the repo root to manage the stack:

- **Start (build + run in background):**
  ```bash
  make
  # Equivalent: docker compose -f ./srcs/docker-compose.yml up -d --build
  ```
- **Stop (pause containers):**
  ```bash
  make stop
  # Equivalent: docker compose -f ./srcs/docker-compose.yml stop
  ```
- **Stop and remove containers & network (keeps named volumes by default):**
  ```bash
  make down
  # Equivalent: docker compose -f ./srcs/docker-compose.yml down
  ```
- **Full cleanup (destructive, removes images/containers):**
  ```bash
  make fclean
  # Careful: may remove images and unused objects
  ```

---

## 🌐 Access the website and administration panel

- **Website:** Open `https://<DOMAIN_NAME>` in your browser (example: `https://msimic.42.fr`).
- **Admin panel:** `https://<DOMAIN_NAME>/wp-admin`  — log in using the WordPress admin credentials.
- If using self-signed certs, accept the browser warning to proceed.

Tip: Replace `<DOMAIN_NAME>` with the value in `srcs/.env` (`DOMAIN_NAME=`).

---

## 🔑 Locate and manage credentials

- Credentials and configuration are stored in `srcs/.env` (do not commit secrets to git). Example variables:
  ```dotenv
  DOMAIN_NAME=msimic.42.fr
  MYSQL_USER=wp_user
  MYSQL_PASSWORD=wp_pass123
  MYSQL_ADMIN=db_master
  MYSQL_ADMIN_PASSWORD=db_admin123
  WP_ADMIN=msimic_wp
  WP_ADMIN_PASSWORD=wp_admin123
  ```
- To change WordPress admin password from the host (using wp‑cli inside the container):
  ```bash
  docker compose exec wordpress wp user update msimic_wp --user_pass='new_password' --allow-root
  ```
- To run SQL commands as admin:
  ```bash
  docker compose exec mariadb mysql -u${MYSQL_ADMIN} -p${MYSQL_ADMIN_PASSWORD} -e "SHOW DATABASES;"
  ```
- Best practice: Keep production secrets in a secret manager or environment that is not committed to source control.

---

## ✅ Check that services are running correctly

- Show running services and their status:
  ```bash
  docker compose -f srcs/docker-compose.yml ps
  ```
- View service logs (live):
  ```bash
  docker compose -f srcs/docker-compose.yml logs -f nginx
  docker compose -f srcs/docker-compose.yml logs -f wordpress
  docker compose -f srcs/docker-compose.yml logs -f mariadb
  ```
- Check health status (if configured):
  ```bash
  docker inspect -f '{{.State.Health.Status}}' mariadb
  ```
- Confirm NGINX TLS config only allows TLSv1.2/1.3:
  ```bash
  docker compose exec nginx nginx -T | grep -i ssl_protocols
  ```
- Quick TLS client check (from host):
  ```bash
  openssl s_client -connect 127.0.0.1:443 -tls1_3
  ```
- Verify PHP‑FPM is listening in WordPress container:
  ```bash
  docker compose exec wordpress ss -ltnp | grep 9000
  ```
- Verify volumes and persistence:
  ```bash
  docker volume ls | grep srcs_
  docker volume inspect srcs_mariadb_data --format '{{ .Mountpoint }}'
  docker volume inspect srcs_wordpress_data --format '{{ .Mountpoint }}'
  ```

---

## 🔧 Useful admin commands & troubleshooting

- Enter a container shell:
  ```bash
  docker compose exec wordpress bash
  docker compose exec mariadb bash
  ```
- Backup a named volume to host:
  ```bash
  docker run --rm -v srcs_mariadb_data:/from -v /home/<login>/backup:/to busybox sh -c "cd /from && tar -czf /to/mariadb_$(date +%F).tgz ."
  ```
- Restore or migrate data carefully; stop containers before moving database files to avoid corruption.

---

## 📌 Final notes

- Keep your `.env` secret and do not share passwords.
- If something is not working, check `docker compose logs -f <service>` and the container health statuses first.
- If you'd like, a short readiness script can be added to `docs/` to run the verification checklist automatically.

---

*Last updated: 2025-12-25*
