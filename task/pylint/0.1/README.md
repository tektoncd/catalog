# pylint

The task provides linting based on [pylint](https://pypi.org/project/pylint/) for Python. The used images are based on the official Docker Hub [Python images](https://hub.docker.com/_/python). The installation of the packages is performed via a `pip install`.

**It is required that `pylint` is part of the requirements file for the task. If the module is not included a warning will be printed.**

## Install the Task

### Workspaces

* **source**: A [Workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md) volume containing the python code.

### Install pylint

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/pylint/0.1/raw
```

## Parameters

* **PYTHON**: The used Python version, more precisely the tag for the Python image (_default_: `latest`)
* **SOURCE_PATH**: The path to the source code (_default_: `.`)
* **MODULE_PATH**: The path to the module which should be analysed by pylint (_default_: `.`)
* **ARGS**: The additional arguments to be used with pylint
* **REQUIREMENTS_FILE**: The name of the requirements file inside the source location (_default_: `requirements.txt`)

## Platforms

The Task can be run on `linux/amd64`, `linux/s390x`, `linux/arm64` and `linux/ppc64le` platforms.

## Usage

This `TaskRun` runs `pylint` on a repository.

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
    persistentVolumeClaim:
      claimName: my-source
  params:
  - name: PYTHON
    value: "3.7"
  - name: MODULE
    value: "examples/custom.py"
  - name: ARGS
    value: "-r y"
```
