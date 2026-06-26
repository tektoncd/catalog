# Kaniko

This Task builds source into a container image using the
[`kaniko`](https://github.com/osscontainertools/kaniko) tool.

>kaniko doesn't depend on a Docker daemon and executes each command within a
>Dockerfile completely in userspace.  This enables building container images in
>environments that can't easily or securely run a Docker daemon, such as a
>standard Kubernetes cluster.
> - [Kaniko website](https://github.com/osscontainertools/kaniko)

kaniko is meant to be run as an image, `ghcr.io/osscontainertools/kaniko:v1.27.6`. This
makes it a perfect tool to be part of Tekton. This task can also be used with Tekton Chains to
attest and sign the image.

## Changelog

- Use a supported replacement (https://github.com/osscontainertools/kaniko) of the original archived
  (https://github.com/GoogleContainerTools/kaniko) repository, so this task is no longer deprecated
- Added `KANIKO_DIR` variable to allow building kaniko with itself, see https://github.com/osscontainertools/kaniko#bootstrapping-kaniko

## Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/kaniko/0.8/raw
```

## Parameters

* **IMAGE**: The name (reference) of the image to build.
* **DOCKERFILE**: The path to the `Dockerfile` to execute (_default:_ `./Dockerfile`)
* **CONTEXT**: The build context used by Kaniko (_default:_ `./`)
* **EXTRA_ARGS**: Additional args to pass to the Kaniko executor.
* **BUILDER_IMAGE**: The Kaniko executor image to use (_default:_ `ghcr.io/osscontainertools/kaniko:v1.27.6`)
* **WRITER_IMAGE**: The image to use for the write-url step (_default:_ `docker.io/library/bash:5.1.4@sha256:c523c636b722339f41b6a431b44588ab2f762c5de5ec3bd7964420ff982fb1d9`)
* **KANIKO_DIR**: Specifies the location of the kaniko binaries (_default:_ `/kaniko`)

## Workspaces

* **source**: A [Workspace](https://github.com/tektoncd/pipeline/blob/master/docs/workspaces.md) containing the source to build.
* **dockerconfig**: An optional [Workspace](https://github.com/tektoncd/pipeline/blob/master/docs/workspaces.md) containing a Docker `config.json`

## Results

* **IMAGE_DIGEST**: The digest of the image just built.
* **IMAGE_URL**: URL of the image just built.

These results are needed by chains to sign the created image. See Chains documentation for more information: https://github.com/tektoncd/chains/blob/main/docs/config.md#chains-type-hinting

## Authentication to a Container Registry

kaniko builds an image and pushes it to the destination defined as a parameter.
In order to properly authenticate to the remote container registry, it needs to
have the proper credentials. This can achieved by using a workspace that contains
the docker `config.json`.

When using a workspace, the workspace shall be bound to a secret that embeds the
configuration file in a key called `config.json`.

## Usage

This TaskRun runs the Task to fetch a Git repo, and build and push a container
image using Kaniko

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: example-run
spec:
  taskRef:
    name: kaniko
  workspaces:
  - name: source
    persistentVolumeClaim:
      claimName: my-source
  - name: dockerconfig
    secret:
      secretName: my-secret
```
