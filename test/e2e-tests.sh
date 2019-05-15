#!/bin/bash

# Copyright 2019 The Tekton Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

source $(dirname $0)/../vendor/github.com/tektoncd/plumbing/scripts/e2e-tests.sh

# Setup a test cluster.
initialize $@

# Install the latest Tekton CRDs.
kubectl apply --filename https://storage.googleapis.com/tekton-releases/latest/release.yaml

set -ex
set -o pipefail
# Validate that all the Task CRDs in this repo are valid by creating them in a NS.
readonly ns="task-ns"
kubectl create ns "${ns}"
for f in $(find ${REPO_ROOT_DIR} -maxdepth 2 -name '*.yaml'); do
    echo "Checking ${f}"
    kubectl apply -f "${f}"
done

success
