# Kubeval

This task makes it possible to use [Kubeval](https://github.com/instrumenta/kubeval) within
your Tekton pipelines. Kubeval is a tool used for validating Kubernetes configuration files.

## Installation

In order to use Kubeval with Tekton you need to first install the task.

```console
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/kubeval/0.1/raw
```

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

Once installed, the task can be used as follows:

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: kubeval-example
spec:
  taskRef:
    name: kubeval
  workspaces:
  - name: source
    persistentVolumeClaim:
      claimName: my-source
```

By default the task will recursively scan the provided repository for YAML files and validate them against the Kubernetes schemas. You can change the default behavious, targetting particular directories, files or Kubernetes versions, using the parameters.

## Parameters

* **files**: The files or directories to test to validate against the schemas
* **output**: Which output format to use (_default:_ `stdout`)
* **args**: An arrag of additional arguments to pass to Kubeval (_defaultt `[]`)

## Workspaces

* **source**: A [Workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md) containing the source to build.
