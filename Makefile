COMPOSE_FILE := srcs/docker-compose.yml
ENV_FILE := srcs/.env

ifneq (,$(wildcard $(ENV_FILE)))
include $(ENV_FILE)
export
endif

LOGIN ?= rapha4lx
DATA_PATH ?= /home/$(LOGIN)/data
DATA_DIR ?= $(DATA_PATH)
COMPOSE := COMPOSE_ENV_FILE=.env docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE)

.PHONY: all up build down clean fclean re logs status ps prepare shell-nginx shell-wordpress shell-mariadb check-env

all: up

up: check-env prepare
	$(COMPOSE) up --build -d

build: check-env prepare
	$(COMPOSE) build

down: check-env
	$(COMPOSE) down

clean: down

fclean: check-env
	$(COMPOSE) down -v --rmi local --remove-orphans

re: fclean up

logs: check-env
	$(COMPOSE) logs -f

status ps: check-env
	$(COMPOSE) ps

prepare:
	mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress

shell-nginx: check-env
	$(COMPOSE) exec nginx sh

shell-wordpress: check-env
	$(COMPOSE) exec wordpress sh

shell-mariadb: check-env
	$(COMPOSE) exec mariadb sh

check-env:
	@test -f $(ENV_FILE) || \
		(echo "Missing $(ENV_FILE). Copy srcs/.env.example to $(ENV_FILE) and fill the values."; exit 1)
