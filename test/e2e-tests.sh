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
source $(dirname $0)/e2e-common.sh

TMPF=$(mktemp /tmp/.mm.XXXXXX)
clean() { rm -f ${TMPF}; }
trap clean EXIT

# Setup a test cluster.
[[ -z ${LOCAL_CI_RUN} ]] && {

    # Initialize cluster
    initialize $@

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
TEST_TASKRUN_IGNORES=${TEST_TASKRUN_IGNORES:-""}

set -ex
set -o pipefail

test_yaml_can_install
test_task_creation */tests

success
