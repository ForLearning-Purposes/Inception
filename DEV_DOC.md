# Inception Developer Documentation

This document outlines the technical details, architecture, and development workflow for the Inception project.

## 🛠 Prerequisites

- Operating System: Linux (VM or native)
- Tools: `docker`, `docker-compose`, `make`, `git`
- Permissions: User must have rights to run docker commands (e.g., added to `docker` group).

## 📂 Project Structure & Setup

The configuration files are located in `srcs/`:
- **docker-compose.yml**: Orchestrates the services.
- **.env**: Stores secrets and environment variables. Do not commit sensitive data in production.

To configure the environment:
1.  Navigate to `srcs/`.
2.  Ensure `.env` exists and contains correct variables (`DOMAIN_NAME`, `MYSQL_...`, `WP_...`).

## 🏗 System Architecture

The project consists of 3 distinct containers communicating via a Docker bridge network (`inception`):

1.  **NGINX (Entrypoint)**
    - Only exposed service (Port 443).
    - Terminates SSL/TLS.
    - Proxies PHP requests to the WordPress container.
    - Serves static assets.

2.  **WordPress (App)**
    - Runs `php-fpm`.
    - Does **not** run NGINX/Apache itself.
    - Connects to MariaDB.
    - Volume: `wordpress_data` mounted at `/var/www/html`.

3.  **MariaDB (Database)**
    - Stores WordPress data.
    - Only listening on network (port 3306 internally).
    - Volume: `mariadb_data` mounted at `/var/lib/mysql`.

## ⚙️ Docker Compose & Makefile

We use `make` to abstract `docker compose` commands.

| Command | Underlying Action | Description |
| :--- | :--- | :--- |
| `make` / `make up` | `docker compose up -d --build` | Builds and runs containers in detached mode. |
| `make down` | `docker compose down -v` | Stops and removes containers and networks. Keeps volumes (by default in some setups, check Makefile flags). |
| `make clean` | `prune` content | Removes unused Docker objects. |

## 💾 Data Persistence

Data is persisted using Docker Names Volumes:
- `mariadb_data`: Stores the raw DB files.
- `wordpress_data`: Stores WP core files, themes, plugins, and uploads.

These volumes enable data recovery even if containers are deleted.