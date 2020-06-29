#!/usr/bin/env bash

# Add an internal PyPI server as sidecar to the task so we can upload it directly
# from our tests without having to go to official PyPI server.
cat ${TMPF} | python -c 'import yaml,sys;data=yaml.load(sys.stdin.read());data["spec"]["sidecars"]=[{"image":"pypiserver/pypiserver:latest", "name":"server", "command":["pypi-server","-P",".","-a",".","/data/packages"], "volumeMounts":[{"name":"packages", "mountPath":"/data/packages"}]}];data["spec"]["volumes"]=[{"name":"packages", "emptyDir":{}}];print(yaml.dump(data, default_flow_style=False));' > ${TMPF}

# Add git-clone
kubectl -n ${tns} apply -f ./git/git-clone.yaml
