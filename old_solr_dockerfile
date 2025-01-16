# Base Image
FROM ubuntu:22.04

# Set environment variables
ENV SOLR_VERSION=8.11.2 \
    SOLR_HOME=/var/solr \
    SOLR_DATA_HOME=/var/solr/data \
    SOLR_USER=solr \
    SOLR_GROUP=solr

# Install required packages
RUN apt-get update && apt-get install -y \
    openjdk-11-jre-headless \
    wget \
    lsof \
    curl \
    unzip \
    procps \
    ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create Solr user and group
RUN groupadd -r $SOLR_GROUP && useradd -r -g $SOLR_GROUP -s /bin/bash -d /var/solr $SOLR_USER

# Download and install Solr
WORKDIR /tmp
RUN wget https://archive.apache.org/dist/lucene/solr/${SOLR_VERSION}/solr-${SOLR_VERSION}.tgz && \
    tar xzf solr-${SOLR_VERSION}.tgz && \
    mv solr-${SOLR_VERSION} /opt/solr && \
    rm solr-${SOLR_VERSION}.tgz

# Set up Solr home directory and copy default solr.xml
RUN mkdir -p $SOLR_HOME/data && \
    cp /opt/solr/server/solr/solr.xml $SOLR_HOME/ && \
    cp -r /opt/solr/server/solr/configsets/_default $SOLR_HOME/data/gocam-solr && \
    chown -R $SOLR_USER:$SOLR_GROUP /opt/solr /var/solr

# Expose Solr port
EXPOSE 8983

# Switch to Solr user
USER $SOLR_USER

CMD ["/opt/solr/bin/solr", "start", "-f"]
