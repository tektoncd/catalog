# Datree Test

[Datree](https://datree.io/) is an open source tool for identifying Kubernetes misconfigurations. It provides a policy enforcement solution to run automatic checks for rule violations.
This `task` can be used to run datree tests.

Task can also be customised with the various parameters that are passed as flags for the datree command.

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/datree/0.2/datree.yaml
```

## Parameters

- **inputPath**: Complete path for the yaml files relative to the workspace path. Should include the yaml file name with extension. (_default:_ `./*.yaml`).
- **cliArguments** - The desired [Datree CLI arguments](https://hub.datree.io/cli-arguments) for the policy check. (_Optional_)
- **isHelmChart** - Specify whether the given path is a Helm chart. If this option is unused, the path will be considered as a regular yaml file. Should be a string of either `true` or `false` (_Optional_)(_default:_ `false`)
- **helmArguments** - The Helm arguments to be used, if the path is a Helm chart. Only necessary when isHelmChart is set to `true`. (_Optional_)
- **isKustomization** - Specify whether the given path is a directory containing a kustomization.yaml file. If this option is unused, the path will be considered as a regular yaml file. Should be a string of either `true` or `false` (_Optional_)(_default:_ `false`)
- **kustomizeArguments** - The Kustomize arguments to be used, if the path is a Kustomization directory. Only necessary when isKustomization is set to `true`. (_Optional_)
- **DATREE_TOKEN_SECRET**: The name of the `secret` holding the datree token (_default:_`datree-token`).
- **DATREE_TOKEN_SECRET_KEY**: The name of the `secret key` holding the datree token (_default:_`DATREE_TOKEN`).
- **datreeImage** - Datree image to run datree. Ensure the image has the datree binary in / (_default:_`docker.io/datree/datree:0.15.22@sha256:85cf78f16e67e08ea9df18ab6d3d823a576bfbcc5937f30629eb4859fdeb3fd1`) Use `docker.io/datree/datree:latest` to use the latest image.


## Workspace

- **source**: Contains Kubernetes `manifests `on which the test has to be performed.


## Secrets

* `Secret` to provide Datree `access token` to authenticate with Datree.

Check [this](https://hub.datree.io/account-token) to get personal access token for `Datree`.

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage


This task expects a secret named datree-token to exists, with a Datree token in `DATREE_TOKEN`.

This task runs the datree tests and outputs the results to the standard output by default. You can also view the results in the [Datree UI](https://app.datree.io).

The task can scan regular k8s manifest files, helm charts and kustomize files.

This task enables performing policy checks on Helm charts, by utilizing the [Datree Helm plugin](https://github.com/datreeio/helm-datree).
To test a Helm chart, simply set the `isHelmChart` parameter to `"true"`, and add any Helm arguments you wish to use to the `helmArguments` parameter.

This task utilizes the Datree CLI's built-in Kustomize support. To use the plugin to test a kustomization, set `isKustomization` to `"true"`, and add any Kustomize arguments you wish to use to the `kustomizeArguments` parameter

The files on which the scan has to be performed must be available in the workspace named `source`. This can be done using 
[git-clone](https://github.com/tektoncd/catalog/blob/main/task/git-clone/0.1/git-clone.yaml) task as shown [here](../0.2/samples/run.yaml).

To run the datree test, the following steps can be followed to get started -

1. Create a secret that contains the [Datree token](https://hub.datree.io/account-token)

`Secrets` can be created as follows:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: datree-token
type: Opaque
stringData:
  TAKEN_TOKEN: $(datree_token)
```

2. Create a workspace for the YAML files.

[This](../0.1/samples) example uses PVC for sharing the files in the workspace, PVC can be created using the following configuration:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: tekton-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi 
``` 

3. Install the datree task

4. Create a TaskRun or a Pipeline with the datree task. An example of the Pipeline and PipelineRun -

```yaml
---
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: datree-pipeline
spec:
  params:
  - name: git_url
    default: https://github.com/kubernetes/examples
    type: string
  workspaces:
    - name: source-code-ws
  tasks:
  - name: git-clone
    taskRef:
      name: git-clone
    workspaces:
    - name: output
      workspace: source-code-ws
    params:
    - name: url
      value: $(params.git_url)
  - name: datree-test
    taskRef:
      name: datree
    workspaces:
    - name: source
      workspace: source-code-ws
    params:
    - name: inputPath
      value: "guestbook/*.yaml"
    - name: cliArguments
      value: "--schema-version 1.20.0"
    - name: DATREE_TOKEN_SECRET
      value: datree-token
    - name: DATREE_TOKEN_SECRET_KEY
      value: DATREE_TOKEN
    - name: datreeImage
      value: docker.io/datree/datreeci:latest
    runAfter:
    - git-clone
---
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  creationTimestamp: null
  generateName: datree-pipeline-run-
  namespace: default
spec:
  params:
  - name: git_url
    value: https://github.com/kubernetes/examples
  pipelineRef:
    name: datree-pipeline
  workspaces:
  - name: source-code-ws
    persistentVolumeClaim:
      claimName: tekton-pvc
    subPath: ~/
status: {}
```
### Note 


- Task uses image from `docker.io/datree/datreeci` which is based on [this Dockerfile](https://github.com/datreeio/datree/blob/main/dockerfiles/image-datreeci/Dockerfile).

## More examples

### Helm charts

```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: datree-pipeline
spec:
  params:
  - name: git_url
    default: https://github.com/grafana/helm-charts
    type: string
  workspaces:
    - name: source-code-ws
  tasks:
  - name: git-clone
    taskRef:
      name: git-clone
    workspaces:
    - name: output
      workspace: source-code-ws
    params:
    - name: url
      value: $(params.git_url)
  - name: datree-test
    taskRef:
      name: datree
    workspaces:
    - name: source
      workspace: source-code-ws
    params:
    - name: inputPath
      value: "charts/fluent-bit"
    - name: cliArguments
      value: "--schema-version 1.22.0 --output JUnit"
    - name: isHelmChart
      value: "true"
    - name: helmArguments
      value: "--set loki.serviceName=loki.default.svc.cluster.local"
    - name: DATREE_TOKEN_SECRET
      value: datree-token
    - name: DATREE_TOKEN_SECRET_KEY
      value: DATREE_TOKEN
    - name: datreeImage
      value: docker.io/datree/datreeci:latest
    runAfter:
    - git-clone
```

### Kustomize

```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: datree-pipeline
spec:
  params:
  - name: git_url
    default: https://github.com/kubeflow/pipelines
    type: string
  workspaces:
    - name: source-code-ws
  tasks:
  - name: git-clone
    taskRef:
      name: git-clone
    workspaces:
    - name: output
      workspace: source-code-ws
    params:
    - name: url
      value: $(params.git_url)
  - name: datree-test
    taskRef:
      name: datree
    workspaces:
    - name: source
      workspace: source-code-ws
    params:
    - name: inputPath
      value: "manifests/kustomize/env/aws"
    - name: cliArguments
      value: "--schema-version 1.22.0 --output JUnit"
    - name: isKustomization
      value: "true"
    - name: datreeImage
      value: docker.io/datree/datreeci:latest
    runAfter:
    - git-clone
```
