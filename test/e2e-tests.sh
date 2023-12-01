#!/usr/bin/env bash

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

# Configure the number of parallel tests running at the same time, start from 0
MAX_NUMBERS_OF_PARALLEL_TASKS=7 # => 8

export RELEASE_YAML=https://github.com/tektoncd/pipeline/releases/download/v0.51.0/release.yaml

source $(dirname $0)/../vendor/github.com/tektoncd/plumbing/scripts/e2e-tests.sh
source $(dirname $0)/e2e-common.sh

E2E_SKIP_CLUSTER_CREATION=${E2E_SKIP_CLUSTER_CREATION:="false"}

TMPF=$(mktemp /tmp/.mm.XXXXXX)
clean() { rm -f ${TMPF}; }
trap clean EXIT

# Setup a test cluster.
[[ -z ${LOCAL_CI_RUN} ]] && {

    # Initialize cluster
    if [ "${E2E_SKIP_CLUSTER_CREATION}" != "true" ]; then
        initialize "$@"
    fi

    # Install the latest Tekton CRDs.
    install_pipeline_crd
}

# You can ignore some yaml tests by providing the TEST_YAML_IGNORES variable
# with the test name separated by a space, for example:
#
# TEST_YAML_IGNORES="kaniko s2i"
#
# will ignore the kaniko and s2i tests,
#
TEST_YAML_IGNORES=${TEST_YAML_IGNORES:-""}

# Allow ignoring some yaml tests, space separated, should be the basename of the
# test for example "s2i"
TEST_TASKRUN_IGNORES=${TEST_TASKRUN_IGNORES:-"maven"}

# Define this variable if you want to run all tests and not just the modified one.
TEST_RUN_ALL_TESTS=${TEST_RUN_ALL_TESTS:-""}

set -ex
set -o pipefail

all_tests=$(echo task/*/*/tests)

function detect_changed_e2e_test() {
    # detect for changes in e2e tests dir
    git --no-pager diff --name-only "${PULL_BASE_SHA}".."${PULL_PULL_SHA}"|grep "^test/[^/]*"
}

[[ -z ${TEST_RUN_ALL_TESTS} ]] && [[ ! -z $(detect_changed_e2e_test) ]] && TEST_RUN_ALL_TESTS=1

function detect_new_changed_tasks() {
    # detect for changes in tests dir of the task
    git --no-pager diff --name-only "${PULL_BASE_SHA}".."${PULL_PULL_SHA}"|grep 'task/[^\/]*/[^\/]*/tests/[^/]*'|xargs -I {} dirname {}|sed 's/\(tests\).*/\1/g'
    # detect for changes in the task manifest
    git --no-pager diff --name-only "${PULL_BASE_SHA}".."${PULL_PULL_SHA}"|grep 'task/[^\/]*/[^\/]*/*[^/]*.yaml'|xargs -I {} dirname {}|awk '{print $1"/tests"}'
}

if [[ -z ${TEST_RUN_ALL_TESTS} ]];then
    all_tests=$(detect_new_changed_tasks|sort -u || true)
    [[ -z ${all_tests} ]] && {
        echo "No tests has been detected in this PR. exiting."
        success
    }
fi

test_yaml_can_install "${all_tests}"

function test_tasks {
    local cnt=0
    local task_to_tests=""

    for runtest in $@;do
        task_to_tests="${task_to_tests} ${runtest}"
        if [[ ${cnt} == "${MAX_NUMBERS_OF_PARALLEL_TASKS}" ]];then
            test_task_creation "${task_to_tests}"
            cnt=0
            task_to_tests=""
            continue
        fi
        cnt=$((cnt+1))
    done

    # in case if there are some remaining tasks
    if [[ -n ${task_to_tests} ]];then
        test_task_creation "${task_to_tests}"
    fi
}

test_tasks "${all_tests}"

success
