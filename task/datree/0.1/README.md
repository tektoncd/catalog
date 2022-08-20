# Datree Test

[Datree](https://datree.io/) is an open source tool for identifying Kubernetes misconfigurations. It provides a policy enforcement solution to run automatic checks for rule violations.
This `task` can be used to run datree tests.

Task can also be customised with the various parameters that are passed as flags for the datree command.

## Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/datree/0.1/raw
```

## Parameters

- **yamlSrc**: Complete path for the yaml files relative to the workspace path. Should include the yaml file name with extension. (_default:_ `./*.yaml`).
- **output**: Output the policy check results in the requested format (simple, json, yaml, xml) (_Optional_).
- **schemaVersion**: Set Kubernetes version to validate against. Defaults to 1.18.0 in Datree (_Optional_).
- **ignoreMissingSchemas**: Skip files with missing schemas instead of failing the schema validation check Should be a string of either `true` or `false` (_Optional_).
- **policy**: Specify which policy to execute (by policy name). Example-staging (_Optional_).
- **onlyK8sFiles**: Skip all non-K8s files.Especially useful when scanning a dir with K8s and other config files. Should be a string of either `true` or `false` (_Optional_).
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

The params `output`, `schemaVersion`, `ignoreMissingSchemas`, `policy` and `onlyK8sFiles` are used to specify the Datree CLI flags `--output`, `--schema-version`, `--ignore-missing-schemas`, `--policy` and `--only-k8s-files` respectively. These params are optional and the respective flag will not be used if the param is not provided.

The files on which the scan has to be performed must be available in the workspace named `source`. This can be done using 
[git-clone](https://github.com/tektoncd/catalog/blob/main/task/git-clone/0.1/git-clone.yaml) task as shown [here](../0.1/samples/run.yaml).

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
    - name: yamlSrc
      value: "guestbook/*.yaml"
    - name: output
      value: json
    - name: schemaVersion
      value: "1.22.0"
    - name: ignoreMissingSchemas
      value: "false"
    - name: policy
      value: Default
    - name: onlyK8sFiles
      value: "true"
    - name: DATREE_TOKEN_SECRET
      value: datree-token
    - name: DATREE_TOKEN_SECRET_KEY
      value: DATREE_TOKEN
    - name: datreeImage
      value: docker.io/datree/datree:latest
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


- Task uses image from `docker.io/datree/datree` which is based on [this Dockerfile](https://github.com/datreeio/datree/blob/main/Dockerfile).
