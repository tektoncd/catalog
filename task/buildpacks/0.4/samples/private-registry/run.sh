#!/bin/sh

# Assume a private Harbor image registry running on k8s.

kubectl create secret docker-registry docker-user-pass \
    --docker-username=admin \
    --docker-password=Harbor12345 \
    --docker-server=https://harbor-core:443 \
    --namespace default

kubectl create -f buildpacks-service-account.yaml -f ../../tests/resources.yaml -f run.yaml
