# Base Image
FROM ubuntu:22.04 as builder

# Set environment variables
ENV PYTHONFAULTHANDLER=1 \
  PYTHONUNBUFFERED=1 \
  PYTHONHASHSEED=random \
  PIP_NO_CACHE_DIR=off \
  PIP_DISABLE_PIP_VERSION_CHECK=on \
  PIP_DEFAULT_TIMEOUT=100 \
  POETRY_VERSION=1.3.2 \
  DEBIAN_FRONTEND=noninteractive \
  SOLR_CORE_NAME=gocam-solr \
  SOLR_HOME=/var/solr/data

# Install required packages
RUN apt-get update && apt-get install -y \
    curl \
    git \
    python3-pip \
    python3 \
    python3-venv \
    nano \
    make \
    openjdk-11-jre-headless \
    wget \
    lsof

# Install Poetry
RUN python3 -m pip install "poetry==$POETRY_VERSION"
RUN poetry self add "poetry-dynamic-versioning[plugin]"

# Install Solr
RUN wget https://archive.apache.org/dist/lucene/solr/8.11.2/solr-8.11.2.tgz && \
    tar xzf solr-8.11.2.tgz && \
    mv solr-8.11.2 /opt/solr && \
    rm solr-8.11.2.tgz

# Create Solr home directory, logs directory, and set permissions
RUN mkdir -p /var/solr/data /opt/solr/server/logs && \
    cp /opt/solr/server/solr/solr.xml /var/solr/data/ && \
    chown -R 8983:8983 /var/solr /opt/solr

USER 8983
# Default command to keep Solr running in the foreground
CMD ["/opt/solr/bin/solr", "start", "-f"]
