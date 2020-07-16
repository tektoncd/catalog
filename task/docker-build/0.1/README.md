# Docker

## Docker-Build

The Docker Build task builds source into a container image using [Docker](https://github.com/docker/). This command executes the directives in the `Dockerfile` to assemble a container image, then pushes that image to a container registry.

### Install the Docker Build Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/task/docker-build/0.1/docker-build.yaml
```

### Parameters

* **image**: The name (reference) of the image to build.
* **builder_image:**: The name of the image containing the Docker tool. See
  note below.  (_default:_ docker.io/docker:latest)
* **dockerfile**: The path to the `Dockerfile` to execute (_default:_
  `./Dockerfile`)
* **context**: Path to the directory to use as context (_default:_
  `.`)
* **build_extra_args**: Extra parameters passed for the build command when
  building images. (_default:_ `""`)
* **push_extra_args**: Extra parameters passed for the push command when
  pushing images. (_default:_ `""`)

### Workspaces

* **source**: A [Workspace](https://github.com/tektoncd/pipeline/blob/master/docs/workspaces.md) volume containing the source to build.


### Usage

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: docker
spec:
  params:
  - name: image
    value: localhost:5000/nocode
  taskRef:
    name: docker
  workspaces:
  - name: source
    persistentVolumeClaim:
      claimName: docker-source-pvc
```