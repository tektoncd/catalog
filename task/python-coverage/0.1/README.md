# Python Coverage

The task provides code coverage based on [coverage](https://coverage.readthedocs.io/en/coverage-5.2.1/) for Python. The used images are based on the official Docker Hub [Python images](https://hub.docker.com/_/python). The installation of the packages is performed via a `pip install`.

**It is required that `pytest` and `coverage` is part of the requirements file for the task. If the module is not included a warning will be printed.**

## Install the Task

### Workspaces

- **source**: A [Workspace](https://github.com/tektoncd/pipeline/blob/master/docs/workspaces.md) volume containing the python code.

### Install pytest

```bash
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/task/python-coverage/0.1/python-coverage.yaml
```

## Parameters

- **PYTHON**: The used Python version, more precisely the tag for the Python image (_default_: `latest`)
- **ARGS**: The additional arguments to be used with pytest
- **SOURCE_PATH**: The path to the source code (_default_: `.`)
- **REQUIREMENTS_FILE**: The name of the requirements file inside the source location (_default_: `requirements.txt`)

## Usage

This `TaskRun` runs `pytest` and `coverage` on a repository.

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: python-coverage-run
spec:
  taskRef:
    name: python-coverage
  workspaces:
    - name: source
      persistentVolumeClaim:
        claimName: my-source
  params:
    - name: PYTHON
      value: "3.7"
    - name: ARGS
      value: "-rfs"
```
