#!/bin/bash

: ${NAMESPACE:="default"}

USAGE=$(cat <<EOF
Usage:
  NAMESPACE=<namespace> ./add-service-account.sh [-a|-d|--apply|--delete]
Options:
  -a, --apply : Install service account, cluster role and cluster role binding.
  -d, --delete : Uninstall service account, cluster role and cluster role binding.
  --help : Display this message
Environment:
  NAMESPACE : Kubernetes namespace. Defaults to "default"
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

sed -e 's|$(namespace)|'"$NAMESPACE"'|' resources/orka-runner.yml.tmpl \
  > resources/orka-runner.yml
kubectl $ACTION -f resources/orka-runner.yml
rm -f resources/orka-runner.yml
