DATA_DIR ?= /home/msimic/data
MARIADB_DIR := $(DATA_DIR)/mariadb
WORDPRESS_DIR := $(DATA_DIR)/wordpress

# Color variables (red)
RED := $(shell printf '\033[0;31m')
RESET := $(shell printf '\033[0m')

all : up

up : prepare-data
	@printf "%s\n\n%s\n\n%s\n" "$(RED)******[UP]$(RESET)" "$(RED)Building and starting all services defined in docker-compose.yml$(RESET)" "$(RED)******$(RESET)"
	@docker compose -f ./srcs/docker-compose.yml up -d --build

prepare-data:
	@printf "%s\n" "$(RED)- Preparing data directories at $(DATA_DIR)$(RESET)"
	@mkdir -p $(MARIADB_DIR) $(WORDPRESS_DIR)
	@chmod 777 $(DATA_DIR) $(MARIADB_DIR) $(WORDPRESS_DIR)

# Export named volumes to host dirs (run after containers have initialized)
export-volumes: up
	@printf "%s\n" "$(RED)- Copying named volumes to host dirs (may need containers to finish initialization)$(RESET)"
	@docker run --rm -u $(shell id -u):$(shell id -g) -v mariadb_data:/from -v $(MARIADB_DIR):/to busybox sh -c "cp -a /from/. /to/" || true
	@docker run --rm -u $(shell id -u):$(shell id -g) -v wordpress_data:/from -v $(WORDPRESS_DIR):/to busybox sh -c "cp -a /from/. /to/" || true
	@printf "\t%s\n" "$(RED)Note: files are copied as your user (uid:$(shell id -u), gid:$(shell id -g)). If you see permission errors later, run 'make fix-perms' or 'sudo make force-clean'$(RESET)"

# Fix ownership/permissions on the host data dir (requires sudo if files are owned by root)
fix-perms:
	@printf "%s\n" "$(RED)- Fixing ownership to current user and setting user-writable perms$(RESET)"
	@sudo chown -R $(shell id -u):$(shell id -g) $(DATA_DIR) || true
	@chmod -R u+rwX $(DATA_DIR) || true

# Force remove data dir as root when normal clean fails
force-clean:
	@printf "%s\n\n%s\n\n%s\n" "$(RED)******[FORCE-CLEAN]$(RESET)" "$(RED)Force removing $(DATA_DIR) as root$(RESET)" "$(RED)******$(RESET)"
	@sudo rm -rf $(DATA_DIR)

down :
	@printf "%s\n\n%s\n\n%s\n" "$(RED)******[DOWN]$(RESET)" "$(RED)Stopping and removing all services defined in docker-compose.yml$(RESET)" "$(RED)******$(RESET)"
	@docker compose -f ./srcs/docker-compose.yml down

stop :
	@printf "%s\n\n%s\n\n%s\n" "$(RED)******[STOP]$(RESET)" "$(RED)Stopping all services defined in docker-compose.yml$(RESET)" "$(RED)******$(RESET)"
	@docker compose -f ./srcs/docker-compose.yml stop

start :
	@printf "%s\n\n%s\n\n%s\n" "$(RED)******[START]$(RESET)" "$(RED)Starting all services defined in docker-compose.yml$(RESET)" "$(RED)******$(RESET)"
	@docker compose -f ./srcs/docker-compose.yml start

status :
	@printf "%s\n\n%s\n\n%s\n" "$(RED)******[STATUS]$(RESET)" "$(RED)Listing all running Docker containers$(RESET)" "$(RED)******$(RESET)"
	@docker ps

clean:
	@printf "%s\n\n%s\n\n%s\n" "$(RED)******[CLEAN]$(RESET)" "$(RED)Stopping and removing all services defined in docker-compose.yml, including associated volumes$(RESET)" "$(RED)******$(RESET)"
	@docker compose -f ./srcs/docker-compose.yml down -v
	@docker system prune -f --volumes

fclean: clean force-clean
	@printf "%s\n\n%s\n\n%s\n" "$(RED)******[FCLEAN]$(RESET)" "$(RED)Performing full cleanup of Docker system:$(RESET)" "$(RED)images, containers, networks, volumes, build cache and unused data$(RESET)"
	@docker system prune -af --volumes

.PHONY: all up prepare-data export-volumes fix-perms force-clean down stop start status clean fclean