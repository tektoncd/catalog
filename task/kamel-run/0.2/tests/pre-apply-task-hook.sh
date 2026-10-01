#!/usr/bin/env bash
add_sidecar_registry ${TMPF}

# Install Camel K operator
wget https://github.com/apache/camel-k/releases/download/v2.0.0/camel-k-client-2.0.0-linux-amd64.tar.gz
tar -xvf camel-k-client-2.0.0-linux-amd64.tar.gz
./kamel install --registry localhost:5000 --registry-insecure --wait

# Add git-clone
add_task git-clone latest
add_task buildah latest
add_task maven latest