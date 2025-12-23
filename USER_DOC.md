# Inception User Guide

This document provides basic instructions for users and administrators of the Inception infrastructure.

## 🚀 Starting and Stopping the Project

The project is managed via a `Makefile` at the root of the repository.

- **Start the infrastructure:**
  ```bash
  make
  ```
  This command builds the Docker images (if not built) and starts the NGINX, WordPress, and MariaDB containers in the background.

- **Stop the services:**
  ```bash
  make stop
  ```
  This pauses the containers.

- **Stop and remove containers (keep data):**
  ```bash
  make down
  ```

- **Clean everything (delete containers, networks, images, and data volumes):**
  ```bash
  make fclean
  ```

## 🌐 Accessing the Website

Once the project is running:

1.  Open your web browser (Chrome or Firefox recommended).
2.  Navigate to: **[https://msimic.42.fr](https://msimic.42.fr)**
3.  Accept the self-signed certificate warning (since we are using a local SSL certificate).

## 🔑 Application Credentials

The default credentials are configured in the `srcs/.env` file.

### WordPress
- **Website URL:** `https://msimic.42.fr`
- **Admin Login:** `msimic_wp`
- **Admin Password:** `wp_admin123`
- **Standard User:** `monika_user`

### Database (MariaDB)
- **Hostname:** `mariadb`
- **Database Name:** `wordpress_db`
- **User:** `wp_user`
- **Password:** `wp_pass123`

## ✅ Basic Checks

- **Nginx:** Responds only on port 443 (HTTPS). HTTP (80) is disabled.
- **WordPress:** Should load the main page. `/wp-admin` loads the dashboard.
- **Data Persistence:** If you restart the containers (`make down` then `make`), your WordPress posts and settings will remain.