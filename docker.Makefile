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

.PHONY: install
install:
	@echo "Creating Python virtual environment and installing dependencies..."
	@$(PYTHON) -m venv $(VENV_DIR)
	@$(VENV_DIR)/bin/pip install --upgrade pip
	@$(VENV_DIR)/bin/pip install poetry
	@$(VENV_DIR)/bin/poetry install

.PHONY: docker-build
docker-build:
	@echo "Building Docker image..."
	docker build --no-cache -t $(IMAGE_NAME) .

.PHONY: docker-run
docker-run:
	@echo "Starting Docker container..."
	docker run -d -p 8983:8983 \
		--name $(CONTAINER_NAME) \
		-v $(PWD)/gocam-solr/conf:/var/solr/data/gocam-solr/conf \
		$(IMAGE_NAME)
	@sleep 5 # Allow Solr to fully start
	@echo "Creating Solr core if it doesn't already exist..."
	@docker exec -it $(CONTAINER_NAME) /opt/solr/bin/solr create_core -c $(SOLR_CORE_NAME) -force || true

.PHONY: rebuild-container
rebuild-container:
	@echo "Stopping and removing existing Docker container..."
	docker stop $(CONTAINER_NAME) || true
	docker rm $(CONTAINER_NAME) || true
	@echo "Removing existing Docker image..."
	docker rmi $(IMAGE_NAME) || true
	@echo "Rebuilding Docker image and starting container..."
	make docker-build
	make docker-run
