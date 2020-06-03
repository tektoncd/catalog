#!/bin/bash

# Add git-clone
kubectl -n ${tns} apply -f ./git/git-clone.yaml

# Add service account
kubectl -n ${tns} create serviceaccount helm-pipeline-run-sa -o yaml --dry-run=client | kubectl apply -f -

# Add edit role to service account
kubectl -n ${tns} create rolebinding helm-pipeline-run-sa-edit --clusterrole edit --serviceaccount ${tns}:helm-pipeline-run-sa -o yaml --dry-run=client | kubectl apply -f -