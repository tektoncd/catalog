# pylint

The task provides linting based on [pylint](https://pypi.org/project/pylint/) for Python.
## Install the Task

### Workspaces

* **source**: A [Workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md) volume containing the python code.

### Install the pylint task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/pylint/0.2/raw
```

## Parameters

* **args**: The arguments to be passed to the pylint CLI. This parameter is required to run this task. (_Default_: `[""]`)
* **path**: The path to the module which should be analysed by pylint. (_Default_: `"."`)
* **requirements_file**: The path to the requirements file to pip install for your application to be checked. (_Default_: `"requirements.txt"`)

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

This `TaskRun` runs `pylint` in a python module directory called `module/`.

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: lint
spec:
  taskRef:
    name: pylint
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
    value: ["-r", "y"]
  - name: path
    value: "module/"
```
