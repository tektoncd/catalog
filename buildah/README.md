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

## Inputs

### Parameters

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

### Resources

* **source**: A `git`-type `PipelineResource` specifying the location of the
  source to build.

## Outputs

### Resources

* **image**: An `image`-type `PipelineResource` specify the image that should
  be built.

## Usage

This TaskRun runs the Task to fetch a Git repo, and build and push a container
image using Buildah.

```
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  name: buildah-build-my-repo
spec:
  taskRef:
    name: buildah
  inputs:
    resources:
    - name: source
      resourceSpec:
        type: git
        params:
        - name: url
          value: https://github.com/my-user/my-repo
  outputs:
    resources:
    - name: image
      resourceSpec:
        type: image
        params:
        - name: url
          value: gcr.io/my-repo/my-image
```

In this example, the Git repo being built is expected to have a `Dockerfile` at
the root of the repository.
