## What is WordPress? 💡
**WordPress** is a PHP‑based content management system (CMS) that serves dynamic web pages backed by a database (here: MariaDB). It provides the site logic, admin UI, themes and plugins — PHP code renders pages and stores content in the database.

---

## How WordPress runs in this project (Inception) 🔧
- **Container & image**
  - Built from Dockerfile. The image installs PHP‑FPM, PHP extensions, `wp-cli`, and a setup script.
- **Boot & setup**
  - Entrypoint is wp-setup.sh. It:
    - Downloads WordPress core if missing (`wp core download`).
    - Waits for MariaDB to be available (`mysqladmin ping`).
    - Creates `wp-config.php` and runs `wp core install` (using env vars).
    - Creates admin/user accounts and installs language if set.
    - Ensures file ownership and then starts `php-fpm8.2`.
  - Key files: www.conf configures PHP‑FPM to listen on `0.0.0.0:9000`.
- **Networking & data**
  - Docker Compose defines the `wordpress` service and a shared named volume `wordpress_data` mounted at `/var/www/html`.
  - `mariadb` is the DB service; `wordpress` connects to it using env vars from .env (`MYSQL_HOST`, `MYSQL_*`).
  - Healthcheck: `php-fpm8.2 -t` (see docker-compose.yml).
- **How it works with NGINX**
  - NGINX (separate container) serves static files from the same `wordpress_data` volume and proxies PHP requests to `wordpress:9000` via FastCGI (`fastcgi_pass wordpress:9000`).

---

## Where to look in the repo 🔎
- Dockerfile: Dockerfile  
- PHP-FPM config: www.conf  
- Setup script: wp-setup.sh  
- Env vars: .env (`DOMAIN_NAME`, `MYSQL_*`, `WP_*`)  
- Compose wiring: docker-compose.yml (services, volumes, networks)

---

## Quick tips ✅
- Change site/admin settings via .env before first run (or use `wp` later).  
- To re-run initial setup, clear the `wordpress_data` volume (this removes installed files & DB data).  
- Use `docker compose logs -f wordpress` to watch the setup script output.

Would you like me to add a short doc snippet to WordPress.md summarizing this (I can draft a concise entry)?