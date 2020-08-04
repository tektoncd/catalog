#!/bin/bash

# Add git-clone task
add_git_clone_task

# Add maven task
kubectl -n ${tns} apply -f ./task/maven/0.1/maven.yaml

# Add skopeo-copy task
kubectl -n ${tns} apply -f ./task/skopeo-copy/0.1/skopeo-copy.yaml

# Add an internal registry as sidecar to the task so we can upload it directly
# from our tests without having to go to an external registry.
add_sidecar_registry ${TMPF}
