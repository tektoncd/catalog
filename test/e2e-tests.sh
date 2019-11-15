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

TMPF=$(mktemp /tmp/.mm.XXXXXX)
clean() { rm -f ${TMPF}; }
trap clean EXIT

LOCAL_CI_RUN=${LOCAL_CI_RUN:-false}

# Setup a test cluster.
[[ -z ${LOCAL_CI_RUN} ]] && {

    # Initialize cluster
    initialize $@
}

# Install the latest Tekton CRDs.
kubectl apply --filename https://storage.googleapis.com/tekton-releases/latest/release.yaml

# You can ignore some yaml tests by providing the TEST_YAML_IGNORES variable
# with the test name separated by a space, for example:
#
# TEST_YAML_IGNORES="kaniko s2i"
#
# will ignore the kaniko and s2i tests,
#
TEST_YAML_IGNORES=${TEST_YAML_IGNORES:-""}

# Allow ignoring some yaml tests, space separated, should be the basename of the test
#
# Disabled by default:
#
# s2i: task is not working by default on vanilla kubernetes (ie not openshift) so disabling it here
TEST_TASKRUN_IGNORES=${TEST_TASKRUN_IGNORES:-"s2i"}

# Specify the default serviceAccount
SERVICE_ACCOUNT=${SERVICE_ACCOUNT:-default}

set -ex
set -o pipefail

function test_yaml_can_install() {
    # Validate that all the Task CRDs in this repo are valid by creating them in a NS.
    readonly ns="task-ns"
    kubectl create ns "${ns}" || true
    for runtest in $(find ${REPO_ROOT_DIR} -maxdepth 2 -name '*.yaml'); do
        skipit=
        for ignore in ${TEST_YAML_IGNORES};do
            [[ ${ignore} == $(basename $(echo ${runtest%.yaml})) ]] && skipit=True
        done
        [[ -n ${skipit} ]] && break
        echo "Checking ${runtest}"
        kubectl -n ${ns} apply -f <(sed "s/namespace:.*/namespace: task-ns/" "${runtest}")
    done
}

function test_task_creation() {
    for runtest in */tests;do
        testname=${runtest%%/*}
        tns="${testname}-$$"
        skipit=

        for ignore in ${TEST_TASKRUN_IGNORES};do
            [[ ${ignore} == ${testname} ]] && skipit=True
        done
        [[ -n ${skipit} ]] && continue

        kubectl create namespace ${tns}

        # Install the task itself first
        for yaml in ${testname}/*.yaml;do
            sed "s/%SERVICE_ACCOUNT%/${SERVICE_ACCOUNT}/g" < ${yaml} > ${TMPF}
            [[ -f ${testname}/tests/pre-apply-task-hook.sh ]] && source ${testname}/tests/pre-apply-task-hook.sh
            cp ${TMPF} /tmp/t.yaml
            kubectl -n ${tns} create -f ${TMPF}
        done

        # Install resource and run
        for yaml in ${runtest}/*.yaml;do
            sed "s/%SERVICE_ACCOUNT%/${SERVICE_ACCOUNT}/g" < ${yaml} > ${TMPF}
            [[ -f ${testname}/tests/pre-apply-taskrun-hook.sh ]] && source ${testname}/tests/pre-apply-taskrun-hook.sh
            cp ${TMPF} /tmp/tr.yaml
            kubectl -n ${tns} create -f ${TMPF}
        done

        while true;do
            status=$(kubectl get -n ${tns} tr --output=jsonpath='{.items[*].status.conditions[*].status}')
            reason=$(kubectl get -n ${tns} tr --output=jsonpath='{.items[*].status.conditions[*].reason}')
            [[ ${status} == "ERROR" || ${reason} == Failed || ${reason} == CouldntGetTask ]] && {
                echo "FAILED: ${testname} task has failed to comeback properly" ;
                echo "--- TR Dump"
                kubectl get -n ${tns} tr -o yaml
                echo "--- Container Logs"
                kubectl get pod -o name -n ${tns}|xargs kubectl logs --all-containers -n ${tns}
                exit 1
            }
            [[ ${status} == True ]] && { echo "SUCCESS: ${testname} taskrun has successfully executed" ; break ;}
            sleep 5
        done

        kubectl delete ns ${tns}
    done
}

test_yaml_can_install
test_task_creation

success
