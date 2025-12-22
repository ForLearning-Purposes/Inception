# Eval Sheet Commands and checks

Here are all commands metioned in eval sheet

# Start

- ensure there are no running container, if there are, delete them and start the project eval.

```bash
docker stop $(docker ps -qa); docker rm
$(docker ps -qa); docker rmi -f $(docker images -qa); docker volume rm $(docker volume ls -q); docker
network rm $(docker network ls -q) 2>/dev/null
```

## Check

### Check before running Makefile:
- "There mustn't be `network: host` in it or `links:`."

- "Examine the Dockerfiles. If you see `tail -f` or any command run in background in any of them in the ENTRYPOINT section, the evaluation ends now. Same thing if `bash` or `sh` are used but not for running a script (e.g, `nginx & bash` or `bash`)."

- check is dockerfiles are built from penultimate stable version of Alpine or Debian - "Examine the Dockerfiles. The containers must be built either from the penultimate stable version of Alpine or Debian."

- If the entrypoint is a script (e.g., ENTRYPOINT ["sh", "my_entrypoint.sh"], ENTRYPOINT ["bash",
"my_entrypoint.sh"]), ensure it runs no program in background (e.g, `nginx & bash`).

- Examine all the scripts in the repository. Ensure none of them runs an infinite loop. The following are a few
examples of prohibited commands: `sleep infinity`, `tail -f /dev/null`, `tail -f /dev/random`

### After running Makefile:

- Ensure that NGINX can be accessed by port 443 only.
- Ensure that a SSL/TLS certificate is used.
- Ensure that the WordPress website is properly installed and configured (you shouldn't see the WordPress Installation page). To access it, open https://login.42.fr (https://login.42.fr) in your browser, where login is the login of the evaluated learner. You shouldn't be able to access the site via http://login.42.fr (http://login.42.fr). If something doesn't work as expected, the evaluation process ends now.
- The Docker images must have the same name as their corresponding service. 
- Ensure that the Makefile has set up all the services via docker compose. This means that the containers must have been built using docker compose and that no crash happened.
- Ensure that docker-network is used by checking the docker-compose.yml file. Then run the `docker network ls` command to verify that a network is visible.
- Using the `docker compose ps` command, ensure that the container was created (using the flag `-p` is authorized if necessary).
- Try to access the service via http (port 80) and verify that you cannot connect.
- The use of a TLS v1.2 or TLS v1.3 certificate is mandatory and must be demonstrated. The SSL/TLS certificate doesn't have to be recognized. A self-signed certificate warning may appear.
- Using the `docker compose ps` command, ensure that the container was created (using the flag `-p` is authorized if necessary).
- Ensure that there is a Volume. To do so: Run the command `docker volume ls` then `docker volume inspect <volume name>`. Verify that the result in the standard output contains the path `/home/login/data/`, where login is the login of the evaluated learner.
- Ensure that you can add a comment using the available WordPress user.