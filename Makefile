all : up

up :
	@docker compose -f ./srcs/docker-compose.yml up -d --build

down :
	@docker compose -f ./srcs/docker-compose.yml down

stop :
	@docker compose -f ./srcs/docker-compose.yml stop

start :
	@docker compose -f ./srcs/docker-compose.yml start

status :
	@docker ps

clean: down
	@docker system prune -f

fclean: clean
	@docker system prune -af

.PHONY: all up down stop start status clean fclean