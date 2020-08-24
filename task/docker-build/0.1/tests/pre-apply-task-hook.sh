#!/usr/bin/env bash

# Add git-clone
kubectl -n ${tns} apply -f ./task/git-clone/0.1/git-clone.yaml