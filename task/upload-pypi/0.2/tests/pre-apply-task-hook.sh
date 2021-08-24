#!/bin/bash

# Add pypiserver sidecar
add_sidecars ${TMPF} '{"image":"pypiserver/pypiserver:latest", "name": "pypiserver", "args": ["-P .", "-a ."]}'

# Add git-clone
add_task git-clone latest
