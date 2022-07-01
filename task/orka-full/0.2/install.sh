#!/bin/bash

set -e

: ${NAMESPACE:="default"}
: ${ORKA_API:="http://10.221.188.100"}

BASE_URL="https://raw.githubusercontent.com/tektoncd/catalog/main/task/orka-full/0.2"
USAGE=$(cat <<EOF
Usage:
  NAMESPACE=<namespace> ORKA_API=<url> ./install.sh [-a|-d|--apply|--delete]
Options:
  -a, --apply : Install orka-full task and config map
  -d, --delete : Uninstall orka-full task and config map
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
    kubectl $ACTION --namespace=$NAMESPACE \
      -f ${BASE_URL}/resources/orka-tekton-config.yaml.tmpl \
      --ignore-not-found
    kubectl $ACTION --namespace=$NAMESPACE -f ${BASE_URL}/orka-full.yaml
    exit 0
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
YAML_TEMPLATE=$(mktemp)
trap "rm -f $YAML_TEMPLATE" EXIT

curl --fail --location ${BASE_URL}/resources/orka-tekton-config.yaml.tmpl --output $YAML_TEMPLATE
sed -e 's|$(url)|'"$ORKA_API"'|' $YAML_TEMPLATE \
  > ${YAML_TEMPLATE}.new
mv ${YAML_TEMPLATE}.new $YAML_TEMPLATE
kubectl $ACTION --namespace=$NAMESPACE -f $YAML_TEMPLATE

# Install tasks
kubectl $ACTION --namespace=$NAMESPACE -f ${BASE_URL}/orka-full.yaml
