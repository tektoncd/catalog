#!/bin/bash

# Add git-clone
kubectl -n ${tns} apply -f ./git/git-clone.yaml
