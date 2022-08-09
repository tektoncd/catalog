#!/usr/bin/env bash
# only used for local quick testing, since this project has its own test run strategy described in CONTRIBUTING.md
#
# USAGE: cd into project root root directory, then execute:
# support/test-local.sh <object_type>/<object_name>/<object_version>
# <object_type>: task|pipeline
# <object_name>: name of the task or pipeline
# <object_version>: the version folder
# Note that this will allow you to code-complete the arg, as the parameter reflects the folder of the task/pipeline
#
# PREREQUISITES:
# - The task/pipeline follows the convention to use the name(do not use generateName):
#   <object_type>-<object_name>-test-pipelinerun
#   Note that even for tasks (where you could theoretically also use a taskrun instead of pipelinerun) this requires
#   that a pipelinerun is used. This urges you to actually check/verify the output of a task, which would require you to
#   run a follow up taskrun anyway (more taskruns -> pipelinerun)!
#
# EXAMPLES:
# support/test-local.sh task/script/0.1
# support/test-local.sh task/script/0.1/

set -ex

# parameters
OBJECT_TO_TEST_FQDN="${1}" # follows pattern: <object_type>/<object_name>/<object_version>

# variables
# shellcheck disable=SC2206
OBJECT_PARSED=(${OBJECT_TO_TEST_FQDN//\// })
OBJECT_TYPE="${OBJECT_PARSED[0]}"
OBJECT_NAME="${OBJECT_PARSED[1]}"
OBJECT_VERSION="${OBJECT_PARSED[2]}"
PIPELINERUN_NAME="${OBJECT_TYPE}-${OBJECT_NAME}-test-pipelinerun"
TESTS_PATH="${OBJECT_TYPE}/${OBJECT_NAME}/${OBJECT_VERSION}/tests"
PRE_APPLY_TASK_SCRIPT="${TESTS_PATH}/pre-apply-task-hook.sh"
PRE_APPLY_TASKRUN_SCRIPT="${TESTS_PATH}/pre-apply-taskrun-hook.sh"

# functions
source test/e2e-common.sh

testFailed() {
  echo "ERROR: To further analyze the failed test, execute:
  'tkn pr describe ${OBJECT_TYPE}-${OBJECT_NAME}-test-pipelinerun'"
  echo "TEST FAILED"
  exit 1
}

testSucceeded() {
  echo
  echo "TEST SUCCESS"
  exit 0
}

# apply task/pipelinerun
[[ -f "${PRE_APPLY_TASK_SCRIPT}" ]] && "${PRE_APPLY_TASK_SCRIPT}"
kubectl apply -f "${OBJECT_TYPE}/${OBJECT_NAME}/${OBJECT_VERSION}/${OBJECT_NAME}.yaml"

# cleanup old testrun
kubectl delete pr --ignore-not-found "${PIPELINERUN_NAME}"

# start new testrun
[[ -f "${PRE_APPLY_TASKRUN_SCRIPT}" ]] && "${PRE_APPLY_TASKRUN_SCRIPT}"
kubectl create -f "${TESTS_PATH}/run.yaml"

# verify new testrun
i=0
while [ $i -lt 300 ]; do
  condition_type="$(kubectl get pr "${PIPELINERUN_NAME}" \
    -o "custom-columns=:status.conditions[0].type" \
    | xargs)"
  condition_status="$(kubectl get pr "${PIPELINERUN_NAME}" -o \
    "custom-columns=:status.conditions[0].status" \
    | xargs)"
  if [[ "${condition_type}" =~ Succeeded && "${condition_status}" =~ True ]]; then
    testSucceeded
  fi
  if [[ "${condition_type}" =~ Succeeded && "${condition_status}" =~ False ]]; then
    testFailed
  fi
  sleep 1
  echo "i=$i"
  ((i+=1))
  echo "i=$i"
done
testFailed
