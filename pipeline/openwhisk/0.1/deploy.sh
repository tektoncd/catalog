#!/usr/bin/env bash

#
# ARGS:
#   COMMAND (default is apply)
#

APPLY="apply"
DELETE="delete"
OPERATION=$APPLY

# Usage details is stored here
USAGE=$(cat <<-END
Usage:
    Environment Variables DOCKER_USERNAME and DOCKER_PASSWORD must be set.
    deploy.sh [-o $APPLY|$DELETE]
    Default: deploy.sh -o $APPLY
END
)

# Fail and display usage if DOCKER_USERNAME is not set in env.
if [[ -z $DOCKER_USERNAME ]]; then
    echo "$USAGE"
    exit 1
fi

# Fail and display usage if DOCKER_PASSWORD is not set in env.
if [[ -z $DOCKER_PASSWORD ]]; then
    echo "$USAGE"
    exit 1
fi

# Read the command line options and set appropriate arguments, including
# --operations|-o
while (( "$#" )); do
  case "$1" in
    -o|--operation)
      OPERATION=$2
      shift 2
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      echo $USAGE
      exit 1
      ;;
  esac
done

# validate operations specified in command line
if [ "$OPERATION" != "$APPLY" ] && [ "$OPERATION" != "$DELETE" ]; then
  echo "Invalid Operation: $OPERATION"
  echo "$USAGE"
  exit 1
fi

# Create a docker registry secret
sed -e 's/${DOCKER_USERNAME}/'"$DOCKER_USERNAME"'/' -e 's/${DOCKER_PASSWORD}/'"$DOCKER_PASSWORD"'/' docker-secret.yaml.tmpl > docker-secret.yaml
kubectl $OPERATION -f docker-secret.yaml

# Create a Service Account called openwhisk-app-builder
# kubectl create serviceaccount openwhisk-app-builder
# Annotate Service Account with Docker Registry secret
# kubectl annotate serviceaccount openwhisk-app-builder secret=dockerhub-user-pass
kubectl $OPERATION -f service-account.yaml

# Create Conditions Detecting Runtimes
kubectl $OPERATION -f conditions/detect-runtimes.yaml

# Create Persistent Volume
kubectl $OPERATION -f workspaces/persistent-volume-claim.yaml

# Clone Application Source
kubectl $OPERATION -f tasks/00-clone-app-repo.yaml

# Clone Runtime Repo
kubectl $OPERATION -f tasks/00-clone-runtime-repo.yaml

# NodeJS Runtime related Tasks
# Create Install Deps Task
kubectl $OPERATION -f tasks/javascript/01-install-deps.yaml

# Create Build Archive Task
kubectl $OPERATION -f tasks/javascript/02-build-archive.yaml

# Create OpenWhisk Task
kubectl $OPERATION -f tasks/javascript/03-openwhisk.yaml

# Python Runtime related Tasks
# Create Install Deps Task
kubectl $OPERATION -f tasks/python/01-install-deps.yaml

# Create Build Archive Task
kubectl $OPERATION -f tasks/python/02-build-archive.yaml

# Create OpenWhisk Task
kubectl $OPERATION -f tasks/python/03-openwhisk.yaml

# Java Runtime related Tasks
# Create Jar file Task
kubectl $OPERATION -f tasks/java/01-create-jar-with-maven.yaml

# Create Build Runtime Task
kubectl $OPERATION -f tasks/java/02-build-runtime-with-gradle.yaml

# Create Build Shared Class Task
kubectl $OPERATION -f tasks/java/03-build-shared-class-cache.yaml

# Create Finalize Runtime Task
kubectl $OPERATION -f tasks/java/04-finalize-runtime-with-function.yaml

# Create Pipeline
kubectl $OPERATION -f openwhisk.yaml

# Run OpenWhisk Pipeline for NodeJS App after replacing DOCKER_USERNAME with user specified name
# sed -e 's/${DOCKER_USERNAME}/'"$DOCKER_USERNAME"'/' pipelinerun/javascript/pipelinerun-build-padding-app.yaml.tmpl > pipelinerun/javascript/pipelinerun-build-padding-app.yaml
# kubectl $OPERATION -f pipelinerun/javascript/pipelinerun-build-padding-app.yaml

# Run OpenWhisk Pipeline for Java App after replacing DOCKER_USERNAME with user specified name
# sed -e 's/${DOCKER_USERNAME}/'"$DOCKER_USERNAME"'/' pipelinerun/java/pipelinerun-java.yaml.tmpl > pipelinerun/java/pipelinerun-java.yaml
# kubectl $OPERATION -f pipelinerun/java/pipelinerun-java.yaml
