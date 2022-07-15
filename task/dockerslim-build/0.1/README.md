# Docker

## Dockerslim-Build

The Dockerslim Build task builds source into a container image using [Dockerslim](https://github.com/docker-slim/docker-slim/). This command executes the directives in the `Dockerfile` to assemble a container image, then pushes that image to a container registry.

### Install the Docker Build Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/dockerslim-build/0.1/raw
```

### Parameters

* **image**: The name (reference) of the image to build.
* **builder_image**: The name of the image containing the Dockerslim tool. See
  note below.  (_default:_ `docker.io/docker:latest`)
* **push_image**: The name of the image containing the Docker tool. See
  note below.  (_default:_ `docker.io/docker:latest`)
* **dind_image**: The name of the image used by `docker-in-docker` sidecar container (_default:_ `docker:dind`). 
* **dockerfile**: The path to the `Dockerfile` to execute (_default:_
  `./Dockerfile`)
* **context**: Path to the directory to use as context (_default:_
  `.`)
* **push_extra_args**: Extra parameters passed for the push command when
  pushing images. (_default:_ `""`)

### Workspaces

* **source**: A [Workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md) volume containing the source to build.

## Platforms

The Task can be run on `linux/amd64` platform.

### Usage

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: docker
spec:
  params:
  - name: image
    value: localhost:5000/squid
  taskRef:
    name: dockerslim-build
  workspaces:
  - name: source
    persistentVolumeClaim:
      claimName: docker-source-pvc
```
