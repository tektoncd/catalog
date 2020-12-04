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

    cat ${TMPF}.read | python3 -c 'import yaml;f=open(0, encoding="utf-8"); data=yaml.load(f.read(), Loader=yaml.FullLoader);data["spec"]["sidecars"]=[{"image":"registry", "name": "registry"}];print(yaml.dump(data, default_flow_style=False));' > ${TMPF}
    rm -f ${TMPF}.read
}

function add_task() {
    local array path_version task
    task=${1}
    if [[ "${2}" == "latest" ]];then
        array=($(echo task/${task}/*/|sort -u))
        path_version=${array[-1]}
	else
		path_version=task/${task}/${2}
        if [[ ! -d ${path_version} ]];then
            echo "I could not find version '${2}' for the task '${task}' in ./task/"
            exit 1
        fi
	fi
    kubectl -n "${tns}" apply -f "${path_version}"/"${task}".yaml
}

function install_pipeline_crd() {
  local latestreleaseyaml
  echo ">> Deploying Tekton Pipelines"
  if [[ -n ${RELEASE_YAML} ]];then
	latestreleaseyaml=${RELEASE_YAML}
  else
    latestreleaseyaml="https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml"
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
    all_tasks="$*"
    kubectl create ns "${ns}" || true
    local runtest
    for runtest in ${all_tasks}; do
        # remove task/ from beginning
        local runtestdir=${runtest#*/}
        # remove /0.1/tests from end
        local testname=${runtestdir%%/*}
        runtest=${runtest//tests}
        runtest="${runtest}${testname}.yaml"
        skipit=
        for ignore in ${TEST_YAML_IGNORES};do
            [[ ${ignore} == "${testname}" ]] && skipit=True
        done
        [[ -n ${skipit} ]] && break
        echo "Checking ${testname}"
        kubectl -n ${ns} apply -f <(sed "s/namespace:.*/namespace: task-ns/" "${runtest}")
    done
}

function show_failure() {
    local testname=$1 tns=$2

    echo "FAILED: ${testname} task has failed to comeback properly" ;
    echo "--- Task Dump"
    kubectl get -n ${tns} task -o yaml
    echo "--- Pipeline Dump"
    kubectl get -n ${tns} pipeline -o yaml
    echo "--- PipelineRun Dump"
    kubectl get -n ${tns} pipelinerun -o yaml
    echo "--- TaskRun Dump"
    kubectl get -n ${tns} taskrun -o yaml
    echo "--- Container Logs"
    for pod in $(kubectl get pod -o name -n ${tns}); do
        kubectl logs --all-containers -n ${tns} ${pod} || true
    done
    exit 1

}
function test_task_creation() {
    local runtest
    declare -A task_to_wait_for

    for runtest in $@;do
        # remove task/ from beginning
        local runtestdir=${runtest#*/}
        # remove /0.1/tests from end
        local testname=${runtestdir%%/*}
        # get version of the task
        local version=$(basename $(basename $(dirname $runtest)))
        # check version is in given format
        [[ ${version} =~ ^[0-9]+\.[0-9]+$ ]] || { echo "ERROR: version of the task is not set properly"; exit 1;}
        # replace . with - in version as not supported in namespace name
        version="$( echo $version | tr '.' '-' )"
        local tns="${testname}-${version}"
        local skipit=

        for ignore in ${TEST_TASKRUN_IGNORES};do
            [[ ${ignore} == ${testname} ]] && skipit=True
        done

        # remove /tests from end
        local taskdir=${runtest%/*}

        # check whether test folder exists or not inside task dir
        # if not then run the tests for next task (if any)
        [ ! -d $runtest ] && skipit=True

        ls ${taskdir}/*.yaml 2>/dev/null >/dev/null || skipit=True

        cat ${taskdir}/*.yaml | grep 'tekton.dev/deprecated: \"true\"' && skipit=True

        [[ -n ${skipit} ]] && continue

        # In case of rerun it's fine to ignore this error
        kubectl create namespace ${tns} >/dev/null 2>/dev/null || :

        # Install the task itself first
        for yaml in ${taskdir}/*.yaml;do
            started=$(date '+%Hh%M:%S')
            echo "${started} STARTING: ${testname}/${version} "
            cp ${yaml} ${TMPF}
            [[ -f ${taskdir}/tests/pre-apply-task-hook.sh ]] && source ${taskdir}/tests/pre-apply-task-hook.sh
            function_exists pre-apply-task-hook && pre-apply-task-hook

            [[ -d ${taskdir}/tests/fixtures ]] && {
                cat <<EOF>>${TMPF}
  sidecars:
  - image: quay.io/chmouel/go-rest-api-test
    name: go-rest-api
    env:
      - name: CONFIG
        value: |
$(cat ${taskdir}/tests/fixtures/*.yaml|sed 's/^/          /')
EOF
            }

            # Make sure we have deleted the content, this is in case of rerun
            # and namespace hasn't been cleaned up or there is some Cluster*
            # stuff, which really should not be allowed.
            kubectl -n ${tns} delete -f ${TMPF} >/dev/null 2>/dev/null || true
            kubectl -n ${tns} create -f ${TMPF}
        done

        # Install resource and run
        for yaml in ${runtest}/*.yaml;do
            cp ${yaml} ${TMPF}
            [[ -f ${taskdir}/tests/pre-apply-taskrun-hook.sh ]] && source ${taskdir}/tests/pre-apply-taskrun-hook.sh
            function_exists pre-apply-taskrun-hook && pre-apply-taskrun-hook

            # Make sure we have deleted the content, this is in case of rerun
            # and namespace hasn't been cleaned up or there is some Cluster*
            # stuff, which really should not be allowed.
            kubectl -n ${tns} delete -f ${TMPF} >/dev/null 2>/dev/null || true
            kubectl -n ${tns} create -f ${TMPF}
        done

        task_to_wait_for["$testname/${version}"]="${tns}|$started"
    done

    # I would refactor this to a function but bash limitation is too great, really need a rewrite the sooner
    # the uglness to pass a hashmap to a function https://stackoverflow.com/a/17557904/145125
    local cnt=0
    local all_status=''
    local reason=''
    local maxloop=60 # 10 minutes max

    set +x
    while true;do
        # If we have timed out then show failures of what's remaining in
        # task_to_wait_for we assume only first one fails this
        [[ ${cnt} == "${maxloop}" ]] && {
            for testname in "${!task_to_wait_for[@]}";do
                target_ns=${task_to_wait_for[$testname]}
                show_failure "${testname}" "${target_ns}"
            done
        }
        [[ -z ${task_to_wait_for[*]} ]] && {
            break
        }

        for testname in "${!task_to_wait_for[@]}";do
            target_ns=${task_to_wait_for[$testname]%|*}
            started=${task_to_wait_for[$testname]#*|}
            # sometimes we don't get all_status and reason in one go so
            # wait until we get the reason and all_status for 5 iterations
            for tektontype in pipelinerun taskrun;do
                for _ in {1..10}; do
                    all_status=$(kubectl get -n ${target_ns} ${tektontype} --output=jsonpath='{.items[*].status.conditions[*].status}')
                    reason=$(kubectl get -n ${target_ns} ${tektontype} --output=jsonpath='{.items[*].status.conditions[*].reason}')
                    [[ ! -z ${all_status} ]] && [[ ! -z ${reason} ]] && break
                    sleep 1
                done
                # No need to check taskrun if pipelinerun has been set
                [[ ! -z ${all_status} ]] && [[ ! -z ${reason} ]] && break
            done

            if [[ -z ${all_status} || -z ${reason} ]];then
                echo "Could not find a created taskrun or pipelinerun in ${target_ns}"
            fi

            breakit=True
            for status in ${all_status};do
                [[ ${status} == *ERROR || ${reason} == *Fail* || ${reason} == Couldnt* ]] && show_failure ${testname} ${target_ns}

                if [[ ${status} != True ]];then
                    breakit=
                fi
            done

            if [[ ${breakit} == True ]];then
                unset task_to_wait_for[$testname]
                [[ -z ${CATALOG_TEST_SKIP_CLEANUP} ]] && kubectl delete ns ${target_ns} >/dev/null
                echo "${started}::$(date '+%Hh%M:%S') SUCCESS: ${testname} testrun has successfully executed" ;
            fi

        done

        sleep 10
        cnt=$((cnt+1))
    done
    set -x
}
