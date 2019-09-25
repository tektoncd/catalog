#!/usr/bin/env bash

#
# ARGS:
#   COMMAND (default is apply)
#

APPLY="apply"
DELETE="delete"

USAGE=$(cat <<-END
Usage:
    Environment Variables DOCKER_USERNAME and DOCKER_PASSWORD must be set.
    deploy.sh [$APPLY|$DELETE]
    Default: deploy.sh $APPLY
END
)


if [[ -z $DOCKER_USERNAME ]]; then
    echo "$USAGE"
    exit 1
fi

if [[ -z $DOCKER_PASSWORD ]]; then
    echo "$USAGE"
    exit 1
fi

if [[ -z $1 ]]; then
    COMMAND=$APPLY
elif [ "$1" == "$APPLY" ] || [ "$1" == "$DELETE" ]; then
    COMMAND=$1
else
    echo "Invalid Command: $1"
    echo "$USAGE"
    exit 1
fi

if [ $COMMAND == $APPLY ]; then
    sed -e 's/${DOCKER_USERNAME}/'"$DOCKER_USERNAME"'/' -e 's/${DOCKER_PASSWORD}/'"$DOCKER_PASSWORD"'/' ../../../../docker-secret.yaml.tmpl > docker-secret.yaml
    kubectl $COMMAND -f docker-secret.yaml
    kubectl $COMMAND -f ../../../../service-account.yaml
fi

##### Create Node.js Application Image for Knative #####
# Create Install Deps Task
kubectl $COMMAND -f ../../tasks/install-deps.yaml
# Create Build Archive Task
kubectl $COMMAND -f ../../tasks/build-archive.yaml
# Create OpenWhisk Task
kubectl $COMMAND -f ../../openwhisk.yaml
# Create Conditions Detecting Runtimes
kubectl $COMMAND -f ../../../../detect-runtimes.yaml
# Create a Pipeline with all three tasks
kubectl $COMMAND -f ../../pipeline.yaml
# Run OpenWhisk Pipeline after replacing DOCKER_USERNAME with user specified name
sed -e 's/${DOCKER_USERNAME}/'"$DOCKER_USERNAME"'/' pipelinerun.yaml.tmpl > pipelinerun.yaml
kubectl $COMMAND -f pipelinerun.yaml


