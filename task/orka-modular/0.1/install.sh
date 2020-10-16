#!/bin/bash

: ${NAMESPACE:="default"}
: ${ORKA_API:="http://10.221.188.100"}

USAGE=$(cat <<EOF
Usage:
  NAMESPACE=<namespace> ORKA_API=<url> ./install.sh [-a|-d|--apply|--delete]
Options:
  -a, --apply : Install all tasks and config map
  -d, --delete : Uninstall all tasks and config map
  --help : Display this message
Environment:
  NAMESPACE : Kubernetes namespace. Defaults to "default"
  ORKA_API : Orka API endpoint. Defaults to "http://10.221.188.100"
EOF
)

if [ -n "$1" ]; then
  if [[ "$1" == "-a" || "$1" == "--apply" ]]; then
    ACTION="apply"
  elif [[ "$1" == "-d" || "$1" = "--delete" ]]; then
    ACTION="delete"
  elif [[ "$1" == "--help" ]]; then
    echo "$USAGE"
    exit 0
  else
    echo -e "Unkown argument: $1\n"
    echo "$USAGE"
    exit 1
  fi
else
  ACTION="apply"
fi

# Install config map
sed -e 's|$(url)|'"$ORKA_API"'|' resources/orka-tekton-config.yaml.tmpl \
  > resources/orka-tekton-config.yaml
kubectl $ACTION --namespace=$NAMESPACE -f resources/orka-tekton-config.yaml
rm -f resources/orka-tekton-config.yaml

# Install tasks
kubectl $ACTION --namespace=$NAMESPACE \
  -f orka-init.yaml \
  -f orka-deploy.yaml \
  -f orka-teardown.yaml
