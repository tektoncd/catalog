#!/bin/bash

set -e

: ${NAMESPACE:="default"}

BASE_URL="https://raw.githubusercontent.com/tektoncd/catalog/main/task/orka-full/0.2"
USAGE=$(cat <<EOF
Usage:
  NAMESPACE=<namespace> SSH_USERNAME=<username> SSH_PASSWORD=<password> ./add-ssh-creds.sh [-a|-d|--apply|--delete]
Options:
  -a, --apply : Install secret with VM SSH credentials.
  -d, --delete : Uninstall secret with VM SSH credentials.
  --help : Display this message
Environment:
  NAMESPACE : Kubernetes namespace. Defaults to "default"
  SSH_USERNAME (required) : Username for SSH access to VM
  SSH_PASSWORD (required) : Password for SSH access to VM
EOF
)

if [ -n "$1" ]; then
  if [[ "$1" == "-a" || "$1" == "--apply" ]]; then
    ACTION="apply"
  elif [[ "$1" == "-d" || "$1" = "--delete" ]]; then
    ACTION="delete"
    kubectl $ACTION --namespace=$NAMESPACE -f ${BASE_URL}/resources/orka-ssh-creds.yaml.tmpl
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

if [[ ! $SSH_USERNAME || ! $SSH_PASSWORD ]]; then
  echo -e "Username and password required!\n"
  echo "$USAGE"
  exit 1
fi

YAML_TEMPLATE=$(mktemp)
trap "rm -f $YAML_TEMPLATE" EXIT

curl --fail --location ${BASE_URL}/resources/orka-ssh-creds.yaml.tmpl --output $YAML_TEMPLATE
sed -e 's|$(username)|'"$SSH_USERNAME"'|' \
  -e 's|$(password)|'"$SSH_PASSWORD"'|' $YAML_TEMPLATE \
  > ${YAML_TEMPLATE}.new
mv ${YAML_TEMPLATE}.new $YAML_TEMPLATE
kubectl $ACTION --namespace=$NAMESPACE -f $YAML_TEMPLATE
