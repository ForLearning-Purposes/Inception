# Eval Sheet Commands and checks

Here are all commands metioned in eval sheet

# Start

- ensure there are no running container, if there are, delete them and start the project eval.

```bash
docker stop $(docker ps -qa); docker rm
$(docker ps -qa); docker rmi -f $(docker images -qa); docker volume rm $(docker volume ls -q); docker
network rm $(docker network ls -q) 2>/dev/null
```

## Before running Makefile:

### General instructions:
- For the entire evaluation process, if you don't know how to check a requirement, or verify anything, the evaluated learner has to help you.
- Ensure that all the files required to configure the application are located inside a srcs folder. The srcs folder must be located at the root of the repository.
- Ensure that a Makefile is located at the root of the repository.
- Before starting the evaluation, run this command in the terminal: "docker stop $(docker ps -qa); docker rm $(docker ps -qa); docker rmi -f $(docker images -qa); docker volume rm $(docker volume ls -q); docker network rm $(docker network ls -q) 2>/dev/null"
- Read the docker-compose.yml file. There mustn't be `network: host` in it or `links:`. Otherwise, the evaluation ends now.
- Read the docker-compose.yml file. There must be `network(s)` in it. Otherwise, the evaluation ends now.
- Examine the Makefile and all the scripts in which Docker is used. There mustn't be `--link` in any of them. Otherwise, the evaluation ends now.
- Examine the Dockerfiles. If you see `tail -f` or any command run in background in any of them in the ENTRYPOINT section, the evaluation ends now. Same thing if `bash` or `sh` are used but not for running a script (e.g, `nginx & bash` or `bash`).
- Examine the Dockerfiles. The containers must be built either from the penultimate stable version of Alpine or Debian.
- If the entrypoint is a script (e.g., ENTRYPOINT ["sh", "my_entrypoint.sh"], ENTRYPOINT ["bash", "my_entrypoint.sh"]), ensure it runs no program in background (e.g, `nginx & bash`).
- Examine all the scripts in the repository. Ensure none of them runs an infinite loop. The following are a few examples of prohibited commands: `sleep infinity`, `tail -f /dev/null`, `tail -f /dev/random`.

### Activity overview
- How Docker and docker compose work
- The difference between a Docker image used with docker compose and without docker compose
- The benefit of Docker compared to VMs
- The pertinence of the directory structure required for this project (an example is provided in the subject's PDF file).

### README check
- The very first line must follow the required format: "This project has been created as part of the 42 curriculum by <login...>" (italicized).
- Check that the README contains at least the required sections: Description, Instructions, Resources (with explanation of how AI was used).
### Documentation check
- USER_DOC.md must provide basic usage instructions for an end user or administrator (start/stop the stack, access the website and admin panel, manage credentials, basic checks).
- DEV_DOC.md must provide developer-oriented instructions (prerequisites, setup, Makefile usage, docker compose commands, data persistence).
## After running Makefile:

### Simple setup
- Ensure that NGINX can be accessed by port 443 only.
- Ensure that a SSL/TLS certificate is used.
- Ensure that the WordPress website is properly installed and configured (you shouldn't see the WordPress Installation page). To access it, open https://login.42.fr (https://login.42.fr) in your browser, where login is the login of the evaluated learner. You shouldn't be able to access the site via http://login.42.fr (http://login.42.fr). If something doesn't work as expected, the evaluation process ends now.
### Docker Basics
- Ensure that every container is built from the penultimate stable version of Alpine/Debian. If a Dockerfile does not start with `FROM alpine:X.X.X` or `FROM debian:XXXXX`, or any other local image, the evaluation process ends now.
- The Docker images must have the same name as their corresponding service. 
- Ensure that the Makefile has set up all the services via docker compose. This means that the containers must have been built using docker compose and that no crash happened.
### Docker Network
- Ensure that docker-network is used by checking the docker-compose.yml file. Then run the `docker network ls` command to verify that a network is visible.
- The evaluated learner has to give you a simple explanation of docker-network.
### NGINX with SSL/TLS
- Using the `docker compose ps` command, ensure that the container was created (using the flag `-p` is authorized if necessary).
- Try to access the service via http (port 80) and verify that you cannot connect.
- The use of a TLS v1.2 or TLS v1.3 certificate is mandatory and must be demonstrated. The SSL/TLS certificate doesn't have to be recognized. A self-signed certificate warning may appear.
### WordPress with php-fpm and its volume
- Ensure that there is no NGINX in the Dockerfile.
- Using the `docker compose ps` command, ensure that the container was created (using the flag `-p` is authorized if necessary).
- Ensure that there is a Volume. To do so: Run the command `docker volume ls` then `docker volume inspect <volume name>`. Verify that the result in the standard output contains the path `/home/login/data/`, where login is the login of the evaluated learner.
- Ensure that you can add a comment using the available WordPress user.
- Sign in with the administrator account to access the Administration dashboard. The Admin username must not include `admin` or `Admin` (e.g., admin, administrator, Admin-login, admin-123, and so forth).
- From the Administration dashboard, edit a page. Verify on the website that the page has been updated.
### MariaDB:
- Ensure that there is no NGINX in the Dockerfile.
- Using the `docker compose ps` command, ensure that the container was created (using the flag `-p` is authorized if necessary).
- Ensure that there is a Volume. To do so: Run the command `docker volume ls` then `docker volume inspect <volume name>`. Verify that the result in the standard output contains the path `/home/login/data/`, where login is the login of the evaluated learner.
- The evaluated learner must be able to explain you how to login into the database. Verify that the database is not empty.
### Configuration modification - during eval
- During the defense, the reviewer must ask the evaluated person to modify the configuration of one service (for example by changing the port it is using). The reviewer is free to choose which service and which new port, as long as the port is available on the system. (me: how to know which port is available) After the change, the evaluated person must rebuild and restart the project. The service must remain accessible and functional with the new configuration.
