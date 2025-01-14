# Variables
VENV_DIR := .venv
PYTHON := python3
# Makefile

# Variables
VENV_DIR := .venv
PYTHON := python3
SOLR_DIR := /opt/solr
SOLR_PORT := 8983
NAME := gocam-solr
SOLR_CORE_NAME := $(NAME)
IMAGE_NAME := $(NAME)
CONTAINER_NAME := $(NAME)

include docker.Makefile

.PHONY: install
install:
	@echo "Creating Python virtual environment and installing dependencies..."
	@$(PYTHON) -m venv $(VENV_DIR)
	@$(VENV_DIR)/bin/pip install --upgrade pip
	@$(VENV_DIR)/bin/pip install poetry
	@$(VENV_DIR)/bin/poetry install

.PHONY: stop
stop:
	@echo "Stopping Docker container..."
	docker stop $(CONTAINER_NAME) || echo "Container '$(CONTAINER_NAME)' is not running."

.PHONY: start
start:
	@echo "Starting Docker container..."
	docker start $(CONTAINER_NAME) || echo "Container '$(CONTAINER_NAME)' does not exist. Please run 'make docker-run' to create and start it."

.PHONY: restart
restart:
	@echo "Restarting Docker container..."
	make stop
	make start
