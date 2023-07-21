# ko

This Task builds source into a container image using [ko](https://ko.build/).


## Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/ko/0.1/raw
```

## Parameters

* **ko-image**: The ko image to use for builds (_default:_ `ghcr.io/ko-build/ko:latest`)
* **main**: The import path of package main (_default:_ `.`)
* **extra-args**: additional arguments to pass to ko build (_default:_ `[]`)
* **KO_DOCKER_REPO**: ko environment variable which identifies where to push images (_default:_ ``)
* **KO_DEFAULTBASEIMAGE**: base image for ko build (_default:_ ``)

## Workspaces

* **source**: A [Workspace](https://github.com/tektoncd/pipeline/blob/master/docs/workspaces.md) containing the source to build.
* **dockerconfig**: Workspace including a docker "config.json". ko will use this authentication configured to push to the image registry.


## Usage

This TaskRun runs the Task to build and push a container image using ko

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: example-run
spec:
  taskRef:
    name: ko
  workspaces:
  - name: source
    persistentVolumeClaim:
      claimName: my-source
```
