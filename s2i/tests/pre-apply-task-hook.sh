#!/bin/bash

# - TMPF is the temporary file where the YAML is processed.
# - We are duplicating the temporary file since we cannot do the manipulation in
#   place (i.e: reading and writing at the same time)
# - Here we simply add a sidecar to our task so we can upload there.
cp ${TMPF} ${TMPF}.read

# Add an internal registry as sidecar to the task so we can upload it directly
# from our tests withouth having to go to an external registry.
cat ${TMPF}.read | python -c 'import yaml,sys;data=yaml.load(sys.stdin.read());data["spec"]["sidecars"]=[{"image":"registry", "name": "registry"}];print(yaml.dump(data, default_flow_style=False));' > ${TMPF}
rm -f ${TMPF}.read
