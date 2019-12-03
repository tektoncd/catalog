#!/usr/bin/env bash

# Copyright 2018 The Tekton Authors
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

# Helper functions for E2E tests.

# Check if we have a specific RELEASE_YAML global environment variable to use
# instead of detecting the latest released one from tektoncd/pipeline releases

RELEASE_YAML=${RELEASE_YAML:-}

source $(dirname $0)/../vendor/github.com/tektoncd/plumbing/scripts/e2e-tests.sh

# Add an internal registry as sidecar to a task so we can upload it directly
# from our tests withouth having to go to an external registry.
function add_sidecar_registry() {
    cp ${1} ${TMPF}.read

    cat ${TMPF}.read | python -c 'import yaml,sys;data=yaml.load(sys.stdin.read());data["spec"]["sidecars"]=[{"image":"registry", "name": "registry"}];print(yaml.dump(data, default_flow_style=False));' > ${TMPF}
    rm -f ${TMPF}.read
}

function install_pipeline_crd() {
  local latestreleaseyaml
  echo ">> Deploying Tekton Pipelines"
  if [[ -n ${RELEASE_YAML} ]];then
	latestreleaseyaml=${RELEASE_YAML}
  else
    latestreleaseyaml=$(curl -s https://api.github.com/repos/tektoncd/pipeline/releases|python -c "import sys, json;x=json.load(sys.stdin);ass=x[0]['assets'];print([ x['browser_download_url'] for x in ass if x['name'] == 'release.yaml'][0])")
  fi
  [[ -z ${latestreleaseyaml} ]] && fail_test "Could not get latest released release.yaml"
  kubectl apply -f ${latestreleaseyaml} ||
    fail_test "Build pipeline installation failed"

  # Make sure thateveything is cleaned up in the current namespace.
  for res in pipelineresources tasks pipelines taskruns pipelineruns; do
    kubectl delete --ignore-not-found=true ${res}.tekton.dev --all
  done

  # Wait for pods to be running in the namespaces we are deploying to
  wait_until_pods_running tekton-pipelines || fail_test "Tekton Pipeline did not come up"
}

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

function show_failure() {
    local testname=$1 tns=$2

    echo "FAILED: ${testname} task has failed to comeback properly" ;
    echo "--- TR Dump"
    kubectl get -n ${tns} tr -o yaml
    echo "--- Container Logs"
    kubectl get pod -o name -n ${tns}|xargs kubectl logs --all-containers -n ${tns}
    exit 1

}
function test_task_creation() {
    for runtest in ${@};do
        local testname=${runtest%%/*}
        local tns="${testname}-$$"
        local skipit=
        local maxloop=60 # 10 minutes max

        for ignore in ${TEST_TASKRUN_IGNORES};do
            [[ ${ignore} == ${testname} ]] && skipit=True
        done
        [[ -n ${skipit} ]] && continue

        kubectl create namespace ${tns}

        # Install the task itself first
        for yaml in ${testname}/*.yaml;do
            cp ${yaml} ${TMPF}
            [[ -f ${testname}/tests/pre-apply-task-hook.sh ]] && source ${testname}/tests/pre-apply-task-hook.sh
            function_exists pre-apply-task-hook && pre-apply-task-hook
            kubectl -n ${tns} create -f ${TMPF}
        done

        # Install resource and run
        for yaml in ${runtest}/*.yaml;do
            cp ${yaml} ${TMPF}
            [[ -f ${testname}/tests/pre-apply-taskrun-hook.sh ]] && source ${testname}/tests/pre-apply-taskrun-hook.sh
            function_exists pre-apply-taskrun-hook && pre-apply-taskrun-hook
            kubectl -n ${tns} create -f ${TMPF}
        done

        local cnt=0
        while true;do
            [[ ${cnt} == ${maxloop} ]] && show_failure ${testname} ${tns}

            status=$(kubectl get -n ${tns} tr --output=jsonpath='{.items[*].status.conditions[*].status}')
            reason=$(kubectl get -n ${tns} tr --output=jsonpath='{.items[*].status.conditions[*].reason}')
            [[ ${status} == *ERROR || ${reason} == *Failed || ${reason} == CouldntGetTask ]] && show_failure ${testname} ${tns}
            [[ ${status} == True ]] && {
                echo -n "SUCCESS: ${testname} taskrun has successfully executed: " ;
                kubectl get pod -o name -n ${tns}|xargs kubectl logs --all-containers -n ${tns}|tail -1
                break
            }
            sleep 10
            cnt=$((cnt+1))
        done

        kubectl delete ns ${tns}
    done
}
