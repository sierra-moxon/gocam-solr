# Makefile for managing the MongoDB Docker container

# Variables
IMAGE_NAME = gocam-mongodb
CONTAINER_NAME = gocam-mongodb

.PHONY: docker-build
docker-build-mongodb:
	@echo "Building Docker image..."
	docker build --no-cache -t $(IMAGE_NAME) -f ./mongodb.Dockerfile .

# Stop the MongoDB container
mongodb-stop:
	@echo "Stopping Docker container..."
	docker stop $(CONTAINER_NAME) || echo "Container '$(CONTAINER_NAME)' is not running."
	docker rm $(CONTAINER_NAME) || echo "Container '$(CONTAINER_NAME)' does not exist."

# Start the MongoDB container
mongodb-start:
	@echo "Starting Docker container..."
	docker run -d --name $(CONTAINER_NAME) -p 27017:27017 $(IMAGE_NAME)

# Recreate the MongoDB container
rebuild-mongodb-container: mongodb-stop
	@echo "Stopping and removing existing Docker container..."
	docker stop $(CONTAINER_NAME) || true
	docker rm $(CONTAINER_NAME) || true
	@echo "Removing existing Docker image..."
	docker rmi $(IMAGE_NAME) || true
	@echo "Rebuilding Docker image and starting container..."
	make docker-build-mongodb
	make docker-run-mongodb

.PHONY: docker-run-mongodb
docker-run-mongodb:
	@echo "Starting Docker container..."
	docker run -d -p 27017:27017 --name $(CONTAINER_NAME) $(IMAGE_NAME)
	@sleep 5 # Allow MongoDB to fully start