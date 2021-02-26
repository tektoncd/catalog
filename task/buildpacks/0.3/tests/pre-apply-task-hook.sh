#!/usr/bin/env bash

# Add an internal registry as sidecar to the task so we can upload it directly
# from our tests without having to go to an external registry.
add_sidecar_registry ${TMPF}

# Add git-clone
add_task git-clone latest
