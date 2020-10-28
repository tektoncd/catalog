#!/bin/bash

set -e

: ${NAMESPACE:="default"}

BASE_URL="https://raw.githubusercontent.com/tektoncd/catalog/master/task/orka-modular/0.1"
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

YAML_TEMPLATE=$(mktemp)
trap "rm -f $YAML_TEMPLATE" EXIT

curl --fail --location ${BASE_URL}/resources/orka-runner.yaml.tmpl --output $YAML_TEMPLATE
sed -e 's|$(namespace)|'"$NAMESPACE"'|' $YAML_TEMPLATE \
  > ${YAML_TEMPLATE}.new
mv ${YAML_TEMPLATE}.new $YAML_TEMPLATE
kubectl $ACTION --namespace=$NAMESPACE -f $YAML_TEMPLATE
