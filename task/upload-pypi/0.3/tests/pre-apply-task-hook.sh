#!/bin/bash

# Add pypiserver sidecar
add_sidecars ${TMPF} '{"image":"pypiserver/pypiserver:v1.4.2", "name": "pypiserver", "args": ["-P .", "-a ."]}'

# Add git-clone
add_task git-clone latest
