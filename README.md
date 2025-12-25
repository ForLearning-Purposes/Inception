*This project has been created as part of the 42 curriculum by [msimic](https://profile.intra.42.fr/users/msimic).*


# Description

Inception is a project where we build and run a PHP-based website using a containerized service architecture with Docker.

The goal of the project is to understand how a web application is deployed using separate services, where each part of the system runs in its own Docker container. These services communicate with each other through a Docker network.

The project includes:
- NGINX as a secure web server (TLS 1.2 / 1.3)
- WordPress (PHP-FPM) as the web application
- MariaDB as the database

Each service is built from a custom Dockerfile, runs in its own container, and has a single responsibility.
The whole infrastructure runs inside a virtual machine, and NGINX is the only public entry point exposed on port 443.

This project focuses on service isolation, container networking, security, and persistent data management using Docker.

### Common Terms and Differences

- **Virtual Machines vs Docker**: Docker containers are lightweight and share the host OS kernel, making them faster to start and more resource-efficient compared to virtual machines, which emulate entire operating systems.
- **Secrets vs Environment Variables**: Secrets provide a more secure way to manage sensitive data like passwords, as they are encrypted and not exposed in plain text like environment variables.
- **Docker Network vs Host Network**: Docker networks allow for better isolation and control over inter-container communication, whereas the host network directly exposes containers to the host's network stack, reducing isolation.
- **Docker Volumes vs Bind Mounts**: Docker volumes are managed by Docker and are better suited for persistent data storage, while bind mounts directly map host directories, offering more flexibility but less abstraction.

# Instructions

### Requirements

- Linux Virtual Machine
- Docker
- Docker Compose
- Make

### Build and Run

1. Clone the repository:

```sh
$ git clone <repository_url> <repo-name>
$ cd <repo-name>
```

2. Configure environment variables: !!! ADD HERE MORE DETAILS !!!

    - Create and edit the .env file inside the srcs directory.
    - Set the domain name and database credentials.

3. Build and start the infrastructure:

```sh
$ make
```

This command builds all Docker images and starts the containers using 4. Docker Compose.

4. Access the website (Click on the link below):
    - [https://msimic.42.fr](https://msimic.42.fr)

5. Stop the infrastructure

```sh
make down
```

# Resources
Below are links to official documentation and reference materials related to Docker, Docker Compose, NGINX, WordPress, and MariaDB, which were used to understand and build this project.

### Technical Resources

- [Docker Docs](https://docs.docker.com)
- [Docker Compose](https://docs.docker.com/compose)
- [MariaDB Docs](https://mariadb.com/docs)
- [NGINX Docs](https://nginx.org/en/docs/beginners_guide.html)
- []()

### AI Usage

AI tools were used to:

- Understand Docker, Docker Compose, and container networking concepts
- Help structure configuration files and documentation
- Clarify system administration concepts and best practices

All AI-generated content was reviewed, adapted, and fully understood before being used in the project.

---

*Last updated: 2025-12-25*