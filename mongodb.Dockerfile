# Use the official Ubuntu Jammy image as the base
FROM ubuntu:22.04

# Set the working directory (optional)
WORKDIR /app

# Install dependencies and MongoDB
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    ca-certificates && \
    wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | \
    tee /etc/apt/sources.list.d/mongodb-org-6.0.list && \
    apt-get update && \
    apt-get install -y mongodb-org && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Expose the default MongoDB port
EXPOSE 27017
EXPOSE 27018

# Set environment variables for MongoDB
ENV MONGO_INITDB_ROOT_USERNAME=admin
ENV MONGO_INITDB_ROOT_PASSWORD=root

# Create necessary directories for MongoDB
RUN mkdir -p /data/db && mkdir -p /data/configdb


CMD ["mongod", "--dbpath", "/data/db", "--logpath", "/var/log/mongodb/mongod.log", "--bind_ip_all"]
# ###############################################
