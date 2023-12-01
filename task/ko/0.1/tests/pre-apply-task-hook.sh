#!/bin/bash

# Add an internal registry as sidecar to the task so we can upload it directly
# from our tests without having to go to an external registry.
add_sidecar_registry ${TMPF}

# Add git-clone
# using git-clone as 0.7 because with latest version, we need to first mark the directory as safe before executing ko
# same can be tracked at https://github.com/ko-build/ko/issues/1153
add_task git-clone 0.7
