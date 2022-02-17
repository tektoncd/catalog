#!/bin/sh

kubectl delete secret docker-user-pass
kubectl delete -f buildpacks-service-account.yaml -f ../../tests/resources.yaml -f run.yaml
