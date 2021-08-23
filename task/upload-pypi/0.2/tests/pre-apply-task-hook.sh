#!/bin/bash

# Add pypiserver sidecar
add_sidecars ${TMPF} '{"image":"registry", "name": "registry", "args": ["-P .", "-a ."]}'

# Add git-clone
add_task git-clone latest
