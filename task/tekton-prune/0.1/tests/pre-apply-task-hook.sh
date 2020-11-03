#!/usr/bin/env bash
set -ex

for i in {1..2};do
    cat <<EOF| kubectl apply -f-
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: scratch-test-${i}
  labels:
    testme: please
spec:
  taskSpec:
    steps:
    - image: hello-world:linux
EOF
    kubectl wait --timeout=180s --for=condition=Succeeded taskrun/scratch-test-${i}
done
