# BuildKit (Daemonless)

This Task builds source into a container image using [Moby BuildKit](https://github.com/moby/buildkit).

This `buildkit-daemonless` Task is similar to [`buildkit`](../../buildkit) but does not need creating `Secret`, `Deployment`, and `Service` resources for setting up the `buildkitd` daemon cluster.

|                  | `buildkit`     | `buildkit-daemonless`|
|------------------|----------------|----------------------|
|Difficulty        | Hard           | Easy                 |
|Supports Rootless | Yes            | Yes                  |
|Cache             | Registry+Local | Registry             |

## Install

```console
$ kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/buildkit-daemonless/0.2/buildkit-daemonless.yaml
task.tekton.dev/buildkit-daemonless created
```

## Parameters

* **IMAGE**: The name (reference) of the image to build.
* **DOCKERFILE**: The path to the `Dockerfile` to execute (_default:_  `Dockerfile`)
* **BUILDKIT_IMAGE**: BuildKit image (_default:_`moby/buildkit:vX.Y.Z-rootless@sha256:...`)

## Workspaces

* **source**: A [Workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md) containing the source to build.
* **dockerconfig**: An optional [Workspace](https://github.com/tektoncd/pipeline/blob/master/docs/workspaces.md) containing a Docker `config.json`

## Authentication to a Container Registry
Buildkit builds an image and pushes it to the destination defined as a parameter.
In order to properly authenticate to the remote container registry, it needs to
have the proper credentials. This can achieved by using a workspace that contains
the docker `config.json`.

When using a workspace, the workspace shall be bound to a secret that embeds the
configuration file in a key called `config.json`.

## Platforms

The Task can be run on `linux/amd64` platform.
