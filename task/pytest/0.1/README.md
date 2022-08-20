# pytest

The task provides test execution based on [pytest](https://pypi.org/project/pytest/) for Python. The used images are based on the official Docker Hub [Python images](https://hub.docker.com/_/python). The installation of the packages is performed via a `pip install`.

**It is required that `pytest` is part of the requirements file for the task. If the module is not included a warning will be printed.**

## Install the Task

### Workspaces

* **source**: A [Workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md) volume containing the python code.

### Install pytest

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/pytest/0.1/raw
```

## Parameters

* **PYTHON**: The used Python version, more precisely the tag for the Python image (_default_: `latest`)
* **ARGS**: The additional arguments to be used with pytest
* **SOURCE_PATH**: The path to the source code (_default_: `.`)
* **REQUIREMENTS_FILE**: The name of the requirements file inside the source location, with fallback to the requirements file in the root location (_default_: `requirements.txt`)

## Platforms

The Task can be run on `linux/amd64`, `linux/s390x`, and `linux/ppc64le` platforms.

## Usage

This `TaskRun` runs `pytest` on a repository.

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: pytest
spec:
  taskRef:
    name: pytest
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