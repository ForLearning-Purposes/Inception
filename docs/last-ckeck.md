I'll list concise commands and expected outputs to verify each requirement; I'll include both config checks and in‑container/network tests.## Quick prep ✅
- Ensure the stack is running:  
  `docker compose up -d`  
- See running services:  
  `docker compose ps`

---

## 1) NGINX with TLSv1.2 or TLSv1.3 only 🔒
- Check config inside the container (fast & reliable):  
  `docker compose exec nginx nginx -T | grep -i ssl_protocols`  
  Expected: `ssl_protocols TLSv1.2 TLSv1.3;`
- Confirm nginx built with SSL support:  
  `docker compose exec nginx nginx -V 2>&1 | grep -i ssl`
- Live handshake tests from the host (should succeed for 1.2/1.3, fail for older):
  - TLS1.2: `openssl s_client -connect 127.0.0.1:443 -tls1_2` → look for `Protocol  : TLSv1.2`
  - TLS1.3: `openssl s_client -connect 127.0.0.1:443 -tls1_3` → look for `Protocol  : TLSv1.3`
  - Old TLS (should be refused): `openssl s_client -connect 127.0.0.1:443 -tls1_1` → connection error or no handshake

> Tip: If host 443 is used elsewhere, replace 127.0.0.1 with your host or test from inside the container.

---

## 2) WordPress + php‑fpm (no nginx) 🧩
- Confirm php‑fpm is installed and running in `wordpress`:  
  `docker compose exec wordpress php-fpm8.2 -v`  
  or `docker compose exec wordpress ps aux | grep php-fpm`
- Confirm php‑fpm is listening on TCP 9000:  
  `docker compose exec wordpress ss -ltnp | grep 9000`  
  Expected: a listening entry for php-fpm (0.0.0.0:9000)
- Confirm **nginx is not** present in `wordpress` container:  
  `docker compose exec wordpress nginx -v || echo "nginx not installed"`  
  (Expected: “command not found” or no nginx processes)
- Verify WordPress files exist:  
  `docker compose exec wordpress test -f /var/www/html/wp-includes/version.php && echo "WP core present"`

---

## 3) MariaDB only (no nginx) 🗄️
- Confirm mysqld is running:  
  `docker compose exec mariadb mysql -V`  
  `docker compose exec mariadb ps aux | grep mysqld`
- Confirm **nginx is not** present in `mariadb` container:  
  `docker compose exec mariadb nginx -v || echo "nginx not installed"`
- Query DB to verify DB/user exist (use env creds from .env):  
  `docker compose exec mariadb mysql -u"${MYSQL_ADMIN}" -p"${MYSQL_ADMIN_PASSWORD}" -e "SHOW DATABASES;"`

---

## 4) Volume for WordPress database (mariadb data) 💾
- List volumes: `docker volume ls | grep mariadb`  
- Inspect volume name: `docker volume inspect <volume_name>`  
- See contents (inside container):  
  `docker compose exec mariadb ls -la /var/lib/mysql`  
  Expect directories like `mysql`, and a folder named after your WP database (e.g., `wordpress_db`)

---

## 5) Volume for WordPress site files (wordpress_data) 📁
- List volumes: `docker volume ls | grep wordpress`  
- Inspect / verify files from either container (shared):  
  `docker compose exec wordpress ls -la /var/www/html`  
  `docker compose exec nginx ls -la /var/www/html`  
  Expect WP files: `index.php`, `wp-includes/`, `wp-admin/`, etc.

---

## 6) Docker network connecting containers 🌐
- Confirm network exists:  
  `docker network ls | grep inception`  
- Inspect network and attached containers:  
  `docker network inspect inception` → look for `Containers` list
- Test connectivity (DNS + reachability):  
  `docker compose exec wordpress ping -c 1 mariadb` (should succeed)  
  `docker compose exec nginx ping -c 1 wordpress` (should succeed)

---

## Quick troubleshooting 🔧
- If commands fail, ensure services are up (`docker compose ps`) and .env is present.  
- Use `docker compose logs -f <service>` to see startup or healthcheck errors.  
- If volumes aren't populated, you may need to restart after clearing old volumes (`docker compose down -v`) — *be careful: destructive*.

---

If you want, I can:
- Add a small QA script that runs these checks automatically, or
- Add these checks to `docs/README` (concise checklist). ✅