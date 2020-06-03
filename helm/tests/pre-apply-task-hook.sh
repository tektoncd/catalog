#!/bin/bash

# Add git-clone
kubectl -n ${tns} apply -f ./git/git-clone.yaml

# Add service account
kubectl -n ${tns} create serviceaccount helm-pipeline-run-sa

# Add edit role to service account
kubectl create rolebinding helm-pipeline-run-sa --clusterrole edit --user helm-sa --namespace ${tns} 