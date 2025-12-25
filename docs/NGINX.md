## What is NGINX? 💡
**NGINX** is a high‑performance web server and reverse proxy used to serve static content, terminate TLS (SSL), and forward dynamic requests (like PHP) to backend services (e.g., PHP‑FPM).  

---

## How NGINX works in this project (Inception) 🔧
- **Image & start-up**
  - Built from Dockerfile. It installs `nginx` and `openssl`, copies SSL certs from `ssl/`, copies the config default.conf into the image, exposes port **443**, and runs `nginx` in the foreground. ✅

- **TLS / domain**
  - TLS is terminated by NGINX using `/etc/nginx/ssl/server.crt` and `server.key`.  
  - The `server_name` is set from the environment variable `DOMAIN_NAME` (see .env).

- **Routing & WordPress integration**
  - The default.conf:
    - Listens on port **443 ssl** and sets `root /var/www/html`.
    - Uses `try_files $uri $uri/ /index.php?$args` for WordPress permalinks.
    - Redirects `/wp-admin` to `/wp-admin/`.
    - For PHP files, it forwards (FastCGI) to `fastcgi_pass wordpress:9000` — i.e., NGINX proxies PHP requests to the `wordpress` service (php‑fpm).
  - Both `nginx` and `wordpress` mount the shared volume `wordpress_data` (see docker-compose.yml), so NGINX can serve static files directly.

- **Docker Compose wiring**
  - `nginx` service is defined in docker-compose.yml, depends on `wordpress` (healthcheck), mounts `wordpress_data`, and maps host `443` → container `443`.

## Why in this project 🔧
- It terminates TLS (uses the certs in ssl) and listens on port 443.
- It serves static files from the shared wordpress_data volume.
- It acts as a reverse proxy / FastCGI gateway for PHP: forwarding .php requests to the wordpress service (fastcgi_pass wordpress:9000) so WordPress (PHP‑FPM) handles dynamic pages.

---

## Quick references 🔎
- Config: default.conf  
- Dockerfile: Dockerfile  
- Env: .env (`DOMAIN_NAME`)  
- Compose: docker-compose.yml (service links + volumes)

---

## Notes / Tips ✅
- To change the domain, edit .env (`DOMAIN_NAME`) and rebuild.  
- Replace `ssl/server.crt` and `ssl/server.key` if you need real certificates.  
- If you need HTTP→HTTPS redirect or other custom rules, add them into default.conf.

If you want, I can show exactly where to add an HTTP-to-HTTPS redirect or help replace the placeholder certs with valid ones.