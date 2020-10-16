#!/bin/bash

: ${NAMESPACE:="default"}

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
    kubectl $ACTION --namespace=$NAMESPACE -f resources/orka-creds.yaml.tmpl
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

sed -e 's|$(email)|'"$EMAIL"'|' \
  -e 's|$(password)|'"$PASSWORD"'|' resources/orka-creds.yaml.tmpl \
  > resources/orka-creds.yaml
kubectl $ACTION --namespace=$NAMESPACE -f resources/orka-creds.yaml
rm -f resources/orka-creds.yaml
