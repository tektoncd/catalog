#!/usr/bin/env bash

TMD=$(mktemp -d)

# Generate SSL Certificate
openssl req -newkey rsa:4096 -nodes -sha256 -keyout "${TMD}"/ca.key -x509 -days 365 \
        -out "${TMD}"/ca.crt -subj "/C=FR/ST=IDF/L=Paris/O=Tekton/OU=Catalog/CN=registry"

# Create a configmap from these certs
kubectl create -n "${tns}" configmap sslcert \
        --from-file=ca.crt="${TMD}"/ca.crt --from-file=ca.key="${TMD}"/ca.key

# Add a secure internal registry as sidecar
kubectl create -n "${tns}" -f task/buildah/0.2/tests/internal-registry/internal-registry.yaml

# Add git-clone
add_task git-clone latest
