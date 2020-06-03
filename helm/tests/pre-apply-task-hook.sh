#!/bin/bash

# Add git-clone
kubectl -n ${tns} apply -f ./git/git-clone.yaml

# Add service account
kubectl -n ${tns} create serviceaccount helm-sa

# Add edit role to service account
kubectl create rolebinding helm-sa-edit --clusterrole edit --user helm-sa --namespace ${tns} 