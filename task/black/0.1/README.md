# Black (Python Code Prettier)

This task can be used to format the python source code using [Black](https://github.com/psf/black) which is an Opinionate Code Formatter.

## Installing the Task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/black/0.1/raw
```

## Parameters

- **args**: The extra params along with the file path needs to be provided as the part of `args`. (_Default_: `["--help"]`)

## Workspaces

- **shared-workspace**: The workspace containing python source code which we want to format. It can be a shared workspace with the `git-clone` task or a `ConfigMap` mounted containing some files.

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

1. Create the `git-clone` task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/git-clone/0.1/raw
```

2. Create the PVC
3. Apply the required tasks

4. Create the Pipeline and PipelineRun for `Black`(Python Code Formatter)

```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: python-formatter-pipeline
spec:
  workspaces:
    - name: shared-workspace
  tasks:
    - name: fetch-repository
      taskRef:
        name: git-clone
      workspaces:
        - name: output
          workspace: shared-workspace
      params:
        - name: url
          value: https://github.com/wumaxd/pylint-pytest-example
        - name: subdirectory
          value: ""
        - name: deleteExisting
          value: "true"
    - name: python-black-run #python code prettier
      taskRef:
        name: black
      runAfter:
        - fetch-repository
      workspaces:
        - name: shared-workspace
          workspace: shared-workspace
      params:
        - name: args
          value: ["."]

---
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: python-formatter-pipeline-run
spec:
  pipelineRef:
    name: python-formatter-pipeline
  workspaces:
    - name: shared-workspace
      persistentvolumeclaim:
        claimName: black-python-pvc
```
