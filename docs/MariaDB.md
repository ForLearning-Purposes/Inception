## What is MariaDB? 💡
**MariaDB** is an open‑source relational database (a MySQL fork) used to store structured data (tables, users, posts, options, etc.). In this project it holds the **WordPress** site data (posts, users, settings).

---

## How MariaDB works in this project 🔧
- **Containerized service** — defined in docker-compose.yml as the `mariadb` service and built from Dockerfile.  
- **Init & config** — the image copies 50-server.cnf (binds to `0.0.0.0`) and runs mariadb-setup.sh as the entrypoint which:
  - Initializes `/var/lib/mysql` on first run,
  - Starts a temporary MariaDB instance on the Unix socket to run setup safely,
  - Creates the database and user accounts using env vars (`MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD`, `MYSQL_ADMIN`, `MYSQL_ADMIN_PASSWORD`), and
  - Shuts the temp server down and starts the real `mysqld` (PID 1).
- **Storage & network** — data is persisted in the named volume `mariadb_data`; the DB is *not* published to the host (no host port) but is reachable by other containers over the internal Docker network (e.g., `wordpress` connects to host `mariadb`).
- **Healthcheck & gating** — Compose uses `mysqladmin ping` (socket) as a healthcheck so `wordpress` can depend on `mariadb:healthy` before starting.

---

## Where to look 🔎
- Dockerfile: Dockerfile  
- Config: 50-server.cnf  
- Setup script: mariadb-setup.sh  
- Env vars: .env (contains `MYSQL_*` values)  
- Compose wiring: docker-compose.yml (service, volume, healthcheck)

---

## Quick notes / tips ✅
- The setup script will exit if required env vars are missing — ensure .env is filled before starting.  
- To inspect DB logs: `docker compose logs -f mariadb`.  
- To reset DB state, remove the `mariadb_data` volume (destructive).  

Would you like a one‑paragraph entry added to MariaDB.md summarizing this?