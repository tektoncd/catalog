#!/bin/bash

set -e

: ${NAMESPACE:="default"}

BASE_URL="https://raw.githubusercontent.com/tektoncd/catalog/main/task/orka-full/0.2"
USAGE=$(cat <<EOF
Usage:
  NAMESPACE=<namespace> EMAIL=<email> PASSWORD=<password> ./add-orka-creds.sh [-a|-d|--apply|--delete]
Options:
  -a, --apply : Install secret with Orka credentials.
  -d, --delete : Uninstall secret with Orka credentials.
  --help : Display this message
Environment:
  NAMESPACE : Kubernetes namespace. Defaults to "default"
  EMAIL (required) : Username for Orka service account, e.g. tekton-svc@macstadium.com
  PASSWORD (required) : Password for Orka service account
EOF
)

if [ -n "$1" ]; then
  if [[ "$1" == "-a" || "$1" == "--apply" ]]; then
    ACTION="apply"
  elif [[ "$1" == "-d" || "$1" = "--delete" ]]; then
    ACTION="delete"
    kubectl $ACTION --namespace=$NAMESPACE -f ${BASE_URL}/resources/orka-creds.yaml.tmpl
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

if [[ ! $EMAIL || ! $PASSWORD ]]; then
  echo -e "Email and password required!\n"
  echo "$USAGE"
  exit 1
fi

YAML_TEMPLATE=$(mktemp)
trap "rm -f $YAML_TEMPLATE" EXIT

curl --fail --location ${BASE_URL}/resources/orka-creds.yaml.tmpl --output $YAML_TEMPLATE
sed -e 's|$(email)|'"$EMAIL"'|' \
  -e 's|$(password)|'"$PASSWORD"'|' $YAML_TEMPLATE \
  > ${YAML_TEMPLATE}.new
mv ${YAML_TEMPLATE}.new $YAML_TEMPLATE
kubectl $ACTION --namespace=$NAMESPACE -f $YAML_TEMPLATE
