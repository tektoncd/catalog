# flake8

The task provides linting based on [flake8](https://pypi.org/project/flake8/) for Python.

## Install the Task

### Workspaces

* **source**: A [Workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md) volume containing the python code.

### Install the flake8 task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/flake8/0.1/raw
```

## Parameters

* **args**: The arguments to be passed to the flake8 CLI. (_Default_: `[""]`)
* **path**: The path to the module which should be analysed by flake8. (_Default_: `"."`)
* **requirements_file**: The path to the requirements file to pip install for your application to be checked. (_Default_: `"requirements.txt"`)

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

This `TaskRun` runs `flake8` in a python module directory called `module/`.

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: lint
spec:
  taskRef:
    name: flake8
  workspaces:
  - name: source
    volumeClaimTemplate:
      spec:
        accessModes:
          - ReadWriteOnce
        resources:
          requests:
            storage: 100Mi
  params:
  - name: args
    value: ["--verbose"]
  - name: path
    value: "module/"
```
