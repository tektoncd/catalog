# Buildah

This Task builds source into a container image using Project Atomic's
[Buildah](https://github.com/projectatomic/buildah) build tool. It uses
Buildah's support for building from
[`Dockerfile`](https://docs.docker.com/engine/reference/builder/)s, using its
`buildah bud` command. This command executes the directives in the `Dockerfile`
to assemble a container image, then pushes that image to a container registry.

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/buildah/buildah.yaml
```

## Parameters

* **IMAGE**: The name (reference) of the image to build.
* **BUILDER_IMAGE:**: The name of the image containing the Buildah tool. See
  note below.  (_default:_ quay.io/buildah/stable:v1.11.0)
* **DOCKERFILE**: The path to the `Dockerfile` to execute (_default:_
  `./Dockerfile`)
* **CONTEXT**: Path to the directory to use as context (_default:_
  `.`)
* **TLSVERIFY**: Verify the TLS on the registry endpoint (for push/pull to a
  non-TLS registry) (_default:_ `true`)
* **FORMAT**: The format of the built container, oci or docker (_default:_
 `oci`)

## Workspaces

* **source**: A `git`-type `PipelineResource` specifying the location of the
  source to build.

## Usage

This TaskRun runs the Task to fetch a Git repo, and build and push a container
image using Buildah.

```
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
