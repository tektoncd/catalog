#!/usr/bin/env bash
#
# Copyright 2020 The Tekton Authors
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



set -x
set -e

# So we can pass thought the set -e
export BUILD_NUMBER=1

cd $(git rev-parse --show-toplevel)
source test/e2e-common.sh


TEST_TASKRUN_IGNORES=${TEST_TASKRUN_IGNORES:-""}

TMPF=$(mktemp /tmp/.mm.XXXXXX)
clean() { rm -f ${TMPF} ;}
trap clean EXIT

if [[ -z ${@} || ${1} == "-h" ]];then
    cat <<EOF
This script will run a single task to help developers testing directly a
single task without sending it to CI.

You need to specify the task name as the first argument and the task version as
the second argument. For example :

${0} git-clone 0.1

will run the tests for git-clone
EOF
    exit 0
fi

TASK=${1}
VERSION=${2}

taskdir=task/${TASK}/${VERSION}

kubectl get ns ${TASK}-${VERSION//./-} >/dev/null 2>/dev/null && kubectl delete ns ${TASK}-${VERSION//./-}

if [[ ! -d ${taskdir}/tests ]];then
    echo "No 'tests' directory is located in ${taskdir}"
    exit 1
fi

test_task_creation task/${TASK}/${VERSION}/tests
