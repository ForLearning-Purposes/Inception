
# 📋 Ready for Evaluation - Cheat Sheet

This document contains answers to the technical questions asked during the evaluation and a guide to verifying the project requirements.

---

## 🧹 Pre-Validation (Clean Slate)

If requested to ensure a clean state before starting:
```bash
docker stop $(docker ps -qa); docker rm $(docker ps -qa); docker rmi -f $(docker images -qa); docker volume rm $(docker volume ls -q); docker network rm $(docker network ls -q) 2>/dev/null
```
*(This command deletes ALL Docker containers, images, volumes, and networks on the machine. Use with caution.)*

---

## 🗣️ Activity Overview (Q&A)

### ❓ How Docker and Docker Compose work?
**Answer:** 
- **Docker** is a platform using OS-level virtualization to deliver software in packages called containers. Containers are lightweight, isolated environments that share the host's OS kernel but have their own filesystem, binaries, and libraries.
- **Docker Compose** is a tool for defining and running multi-container Docker applications. It uses a YAML file (`docker-compose.yml`) to configure the application's services, networks, and volumes, allowing you to start the entire stack with a single command (`docker compose up`).

### ❓ Difference between a Docker image used with vs. without Docker Compose?
**Answer:**
- Technically, the **image itself is the same**.
- **Without Compose:** You must manually build the image (`docker build -t name .`) and manually run it, specifying strictly every long flag for ports, volumes, networks, and env variables (`docker run -p 443:443 -v ...`).
- **With Compose:** The build context, arguments, and runtime configurations (ports, volumes, envs) are defined in the `docker-compose.yml`. Compose handles the build and run process automatically, ensuring consistency and linking services together on a dedicated network.

### ❓ Benefit of Docker compared to VMs?
**Answer:**
- **Efficiency:** Docker containers share the host Linux kernel. They don't need a full guest OS for each app (unlike VMs), making them much lighter (MBs vs GBs) and faster to start (seconds vs minutes).
- **Portability:** "Build once, run anywhere." A container runs the same on a developer's laptop and a production server.
- **Isolation:** Provides process and filesystem isolation without the overhead of hardware virtualization.

### ❓ Pertinence of the directory structure?
**Answer:**
- The structure is **modular and decoupled**.
- `srcs/docker-compose.yml` is the orchestrator at the root of the source.
- `srcs/requirements/<service>/` isolates the configuration for each service (NGINX, WordPress, MariaDB).
- Each folder contains the `Dockerfile` and specific config assets (scripts, `.conf` files) relevant ONLY to that service. This makes maintenance easier; if you need to fix NGINX, you go to the NGINX folder.

---

## 🔍 Technical verifications

### 🌐 Docker Network
**Explanation:**
- We define a custom bridge network named `inception` in `docker-compose.yml`.
- All services (`nginx`, `wordpress`, `mariadb`) join this network.
- **Concept:** Docker provides automatic **DNS resolution** for containers on the same custom network. This allows WordPress to connect to the database simply by using the hostname `mariadb` (the service name), without needing to know IP addresses.
- **Verification:**
  ```bash
  docker network ls
  # You should see 'inception' (or 'srcs_inception')
  docker network inspect srcs_inception
  ```

### 🔐 SSL/TLS (NGINX)
- **Check:** `docker compose ps` (NGINX should be running).
- **Check:** Try accessing `http://msimic.42.fr` (Port 80). **Should fail/refuse connection.**
- **Check:** Access `https://msimic.42.fr` (Port 443). **Should work.**
- **Certificate:** We use a self-signed certificate (generated in the Dockerfile/script or pre-generated). The browser will warn you, which is expected.
- **TLS Version:** Configured in `nginx.conf` (`ssl_protocols TLSv1.2 TLSv1.3;`).

### 🍃 WordPress & Volume
- **Volume Inspection:**
  ```bash
  docker volume ls
  docker volume inspect srcs_wordpress_data
  ```
  *Result should show Mountpoint containing:* `/home/msimic/data/` (or the path defined in your `.env` or Makefile).
- **Functionality:** Login to WP Admin. Create a post/comment.
- **Persistence:** Run `make down` (stops & removes containers), then `make`. The post you created should still be there.

### 💾 MariaDB & Volume
- **Volume Inspection:**
  ```bash
  docker volume inspect srcs_mariadb_data
  ```
- **Login to Database (How-To):**
  You can connect from inside the container:
  ```bash
  docker exec -it mariadb mariadb -u root -p
  # Enter root password (from .env)
  ```
  Or verify it's not empty:
  ```sql
  SHOW DATABASES;
  USE wordpress_db;
  SHOW TABLES;
  SELECT * FROM wp_users;
  ```

---

## 🔄 Configuration Modification (Defense Scenario)

**Task:** "Modify the configuration of one service (e.g., change NGINX port)."

**Steps to perform if asked:**
1.  **Stop the project:** `make stop`
2.  **Edit `srcs/docker-compose.yml`:**
    Change port mapping for nginx:
    ```yaml
    ports:
      - "444:443"  # Change host port to 444
    ```
3.  **Restart:** `make up` (or `make` to rebuild if necessary).
4.  **Verify:** Access `https://msimic.42.fr:444`.

*(Note: If they ask to change the internal listening port of NGINX, you would also need to edit `nginx/conf/default.conf` to `listen 444 ssl;`, update the `Dockerfile` to `EXPOSE 444`, and update `docker-compose.yml` to `"444:444"`).*
