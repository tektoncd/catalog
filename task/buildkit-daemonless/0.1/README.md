# BuildKit (Daemonless)

This Task builds source into a container image using [Moby BuildKit](https://github.com/moby/buildkit).

This `buildkit-daemonless` Task is similar to [`buildkit`](../../buildkit) but does not need creating `Secret`, `Deployment`, and `Service` resources for setting up the `buildkitd` daemon cluster.

|                  | `buildkit`     | `buildkit-daemonless`|
|------------------|----------------|----------------------|
|Difficulty        | Hard           | Easy                 |
|Supports Rootless | Yes            | No (BuildKit per se supports, but [Tekton doesn't support](https://github.com/tektoncd/pipeline/issues/852))|
|Cache             | Registry+Local | Registry             |

## Install

```console
$ kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/buildkit-daemonless/0.1/raw
task.tekton.dev/buildkit-daemonless created
```

## Parameters

* **DOCKERFILE**: The path to the `Dockerfile` to execute (_default:_  `./Dockerfile`)
* **BUILDKIT_IMAGE**: BuildKit image (_default:_`moby/buildkit:vX.Y.Z@sha256:...`)

## Workspaces

* **source**: A [Workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md) containing the source to build.

## Resources

### Outputs

* **image**: An `image`-type `PipelineResource` specifying the image that should be built.
  Currently, generating [`resourceResult`](https://github.com/tektoncd/pipeline/blob/main/docs/resources.md#image-resource) is not supported. ([`buildkit#993`](https://github.com/moby/buildkit/issues/993))

## Platforms

The Task can be run on `linux/amd64` platform.
