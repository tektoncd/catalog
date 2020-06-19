# Publish-Python-Package

This Task publishes Python packages to PyPI index using [Twine](https://pypi.org/project/twine/) utility module. It provides build system independent uploads of source and binary distribution artifacts for both new and existing projects.

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/python/publish-package/update-pypi.yaml
```

## Requirement

Secret is needed with Twine credentials(TWINE_USERNAME:TWINE_PASSWORD) to be provided for python module publishing to PyPI index.

- **username**: The username to authenticate to the repository (package index).
- **password**: The password to authenticate to the repository (package index).

```
apiVersion: v1
kind: Secret
metadata:
  name: pypi-secret
type: kubernetes.io/basic-auth
stringData:
  username: foo
  password: bar
```

## Workspaces

- **source**: A `git`-type `PipelineResource` specifying the location of the source to build.

## Usage

This TaskRun runs the Task to fetch a Git repo, and build and publishes a python module.

```
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: publish-package
spec:
  taskRef:
    name: upload-pypi
  workspaces:
  - name: source
    persistentVolumeClaim:
      claimName: my-source
```

In this example, the Git repo being used is expected to have a `setup.py` file at the root of the repository. [setup.py](https://packaging.python.org/tutorials/packaging-projects/#creating-setup-py) is build script for [setuptools](https://pypi.org/project/setuptools/)
