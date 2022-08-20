# Buildah

This Task builds source into a container image using Project Atomic's
[Buildah](https://github.com/projectatomic/buildah) build tool. It uses
Buildah's support for building from
[`Dockerfile`](https://docs.docker.com/engine/reference/builder/)s, using its
`buildah bud` command. This command executes the directives in the `Dockerfile`
to assemble a container image, then pushes that image to a container registry.

## Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/buildah/0.5/raw
```

## Parameters

* **IMAGE**: The name (reference) of the image to build.
* **BUILDER_IMAGE:**: The name of the image containing the Buildah tool. See
  note below.  (_default:_ quay.io/buildah/stable:v1.23.3)
* **DOCKERFILE**: The path to the `Dockerfile` to execute (_default:_
  `./Dockerfile`)
* **CONTEXT**: Path to the directory to use as context (_default:_
  `.`)
* **TLSVERIFY**: Verify the TLS on the registry endpoint (for push/pull to a
  non-TLS registry) (_default:_ `true`)
* **FORMAT**: The format of the built container, oci or docker (_default:_
 `oci`)
* **BUILD_EXTRA_ARGS**: Extra parameters passed for the build command when
  building images. (_default:_ `""`)
* **PUSH_EXTRA_ARGS**: Extra parameters passed for the push command when
  pushing images. (_default:_ `""`)
* **SKIP_PUSH**: Skip pushing the built image (_default:_ `false`)

## Workspaces

* **source**: A [Workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md) containing the source to build.
* **sslcertdir**: An [*optional* Workspace](https://github.com/tektoncd/pipeline/blob/v0.17.0/docs/workspaces.md#optional-workspaces) containing your custom SSL certificates to connect to the registry. Buildah will look for files ending with *.crt, *.cert, *.key into this workspace. See [this sample](./samples/openshift-internal-registry.yaml) for a complete example on how to use it with OpenShift internal registry.
- **dockerconfig**: An [optional workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md#using-workspaces-in-tasks) that allows providing a `.docker/config.json` file for Buildah to access the container registry. The file should be placed at the root of the Workspace with name `config.json`. See [this sample](./samples/dockerconfig.yaml) for a complete example on how to use `dockerconfig` to access container registry. _(optional)_

## Platforms

The Task can be run on `linux/amd64`, `linux/s390x`, `linux/arm64` and `linux/ppc64le` platforms.

## Usage

This TaskRun runs the Task to fetch a Git repo, and build and push a container
image using Buildah.

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: buildah-build-my-repo
spec:
  taskRef:
    name: buildah
  params:
  - name: IMAGE
    value: gcr.io/my-repo/my-image
  workspaces:
  - name: source
    persistentVolumeClaim:
      claimName: my-source
```

In this example, the Git repo being built is expected to have a `Dockerfile` at
the root of the repository.
