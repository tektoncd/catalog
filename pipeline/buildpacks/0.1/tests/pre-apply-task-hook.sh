#!/usr/bin/env bash

# Add an internal registry as sidecar to the task so we can upload it directly
# from our tests without having to go to an external registry.
add_sidecar_registry ${TMPF}

# Add dependency tasks
add_task git-clone 0.7
add_task buildpacks latest
add_task buildpacks-phases latest
