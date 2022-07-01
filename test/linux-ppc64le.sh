#!/usr/bin/env bash

# Copyright 2021 The Tekton Authors
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

# ppc64le specific registry
export REGISTRY_IMAGE=ibmcom/registry:2.6.2.5
# Maven image to use for ppc64le maven tasks
export MAVEN_IMAGE=maven:3.6.3-adoptopenjdk-11
# Architecture to use for golang tasks
export GOARCH=ppc64le
# Gradle image to use for ppc64le gradle tasks
export BUILDER_IMAGE=gradle:5.6.2-jdk11
# Tasks to skip so far for ppc64le
export TEST_TASKRUN_IGNORES="helm-upgrade-from-repo helm-upgrade-from-source golang-test kaniko"

echo "Add extra MAVEN_IMAGE parameter"
find task/*maven*/*/tests/run.yaml | xargs -I{} yq eval '(..|select(.kind?=="Pipeline")|select(.metadata.name?=="jib-maven-test-pipeline"|"maven-test-pipeline")|.spec.tasks[1].params) |= . +{"name": "MAVEN_IMAGE","value": env(MAVEN_IMAGE)}' -i {}

echo "Change registry image value"
find task -name *registry*.yaml | xargs -I{} yq eval '(..|select(.kind?=="Deployment")|select(.metadata.name?=="registry")|.spec.template.spec.containers[0].image)|= env(REGISTRY_IMAGE)' -i {}

echo "Change GOARCH parameter value"
find task/golang*/*/tests/run.yaml | xargs -I{} yq eval '(..|select(.kind?=="Pipeline")|.spec.tasks[1].params) |= . +{"name": "GOARCH","value": env(GOARCH)}' -i {}

echo "Add extra GRADLE_IMAGE value"
find task/gradle/*/tests/run.yaml | xargs -I{} yq eval '(..|select(.kind?=="Pipeline")|.spec.tasks[1].params) |= . +{"name": "GRADLE_IMAGE","value": env(BUILDER_IMAGE)}' -i {}

echo "Add extra BUILDER_IMAGE parameter"
find task/jib-gradle/*/tests/run.yaml | xargs -I{} yq eval '(..|select(.kind?=="Pipeline")|.spec.tasks[1].params) |= . +{"name": "BUILDER_IMAGE","value": env(BUILDER_IMAGE)}' -i {}
