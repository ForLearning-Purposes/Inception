# Docker — Quick Checks & Common Commands

## Check Docker is installed
```sh
$ docker --version
$ which docker (or where docker on Windows)
$ docker info  # returns daemon info if running and user can access Docker
```
## Check Docker daemon is running
#### Quick check (works if daemon responds):
```sh
    $ docker ps
    $ docker info
```
#### Linux (systemd):
```sh
    $ sudo systemctl status docker
    $ sudo systemctl start docker
```
#### macOS (Docker Desktop):
```sh
    $ pgrep -x Docker || echo "not running"
    $ open --background -a Docker  # start Docker Desktop
```
#### Windows (Docker Desktop, PowerShell):
```sh
    $ Get-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue
    $ Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
```

## Check Docker Compose
#### New CLI plugin:
```sh
    $ docker compose version
```
#### Legacy standalone:
```sh
    $ docker-compose --version
```

## Start Docker Desktop from command line
#### macOS:
```sh
    $ open --background -a Docker
```
#### Windows (PowerShell):
```sh
    $ Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
```
#### Linux (daemon):
```sh
    $ sudo systemctl start docker
```

## Basic Docker commands
#### Run a test container:
```sh
    $ docker run --rm hello-world
```
#### Run detached with port mapping:
```sh
    $ docker run -d --name myapp -p 8080:80 image:tag
```
#### List containers:
```sh
    $ docker ps
    $ docker ps -a
```
#### Images:
```sh
    $ docker images
    $ docker pull image:tag
    $ docker rmi image:tag
```
#### Manage containers:
```sh
    $ docker stop <container>
    $ docker start <container>
    $ docker restart <container>
    $ docker rm <container>
```
#### Build and inspect:
```sh
    $ docker build -t myimage:tag .
    $ docker logs -f <container>
    $ docker exec -it <container> /bin/sh  # or /bin/bash
```

## Basic Docker Compose commands
#### Start services (foreground):
```sh
    $ docker compose up
```
#### Start services (detached):
```sh
    $ docker compose up -d
```
#### Rebuild and start:
```sh
    $ docker compose up --build -d
```
#### Stop and remove:
```sh
    $ docker compose down
```
#### Build only:
```sh
    $ docker compose build
```
#### Logs and status:
```sh
    $ docker compose logs -f
    $ docker compose ps
```
#### Run a command in a service:
```sh
    $ docker compose exec <service> sh  # or bash
```

Notes:
- Use sudo or ensure your user is in the docker group on Linux if you get permission errors.
- Prefer the modern `docker compose` plugin where available; fallback to `docker-compose` if not installed.
- Replace placeholders (image:tag, <container>, <service>) with actual names.