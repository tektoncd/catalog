# Publish-Python-Package

This Task publishes Python packages to PyPI index using [Twine](https://pypi.org/project/twine/) utility module. It provides build system independent uploads of source and binary distribution artifacts for both new and existing projects.

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/task/upload-pypi/0.1/upload-pypi.yaml
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

* **source**: A [Workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md) containing the source to build.

## Platforms

The Task can be run on `linux/amd64` platform.

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

This TaskRun outputs several `Results`:

- A `sha256` hash for each uploaded file (the bdist and the sdist packages).
- The name of the uploaded package
- The version of the uploaded package

This looks like:

```
  taskResults:
  - name: bdist_sha
    value: 97dd35b7097443b6896734d979a1a52c64023f17474e4027d69d2df0b9acb797  dist/foo.whl
  - name: package_name
    value: foo
  - name: package_version
    value: 2.24.4
  - name: sdist_sha
    value: 8fda69bc68ece690d135d0091ebdd10a8c15db477c2eafce0d0a65bc9712f5bf  dist/foo.tar.gz
```
