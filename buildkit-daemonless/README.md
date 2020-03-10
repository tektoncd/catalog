# BuildKit (Daemonless)

This Task builds source into a container image using [Moby BuildKit](https://github.com/moby/buildkit).

This `buildkit-daemonless` Task is similar to [`buildkit`](../buildkit) but does not need creating `Secret`, `Deployment`, and `Service` resources for setting up the `buildkitd` daemon cluster.

|                  | `buildkit`     | `buildkit-daemonless`|
|------------------|----------------|----------------------|
|Difficulty        | Hard           | Easy                 |
|Supports Rootless | Yes            | No (BuildKit per se supports, but [Tekton doesn't support](https://github.com/tektoncd/pipeline/issues/852))|
|Cache             | Registry+Local | Registry             |

## Install

```console
$ kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/buildkit-daemonless/buildkit-daemonless.yaml
task.tekton.dev/buildkit-daemonless created
```

## Parameters

* **DOCKERFILE**: The path to the `Dockerfile` to execute (_default:_  `./Dockerfile`)
* **BUILDKIT_IMAGE**: BuildKit image (_default:_`moby/buildkit:vX.Y.Z@sha256:...`)

## Workspaces

* **source**: A `git`-type `PipelineResource` specifying the location of the source to build.

## Resources

### Outputs

* **image**: An `image`-type `PipelineResource` specifying the image that should be built.
  Currently, generating [`resourceResult`](https://github.com/tektoncd/pipeline/blob/master/docs/resources.md#image-resource) is not supported. ([`buildkit#993`](https://github.com/moby/buildkit/issues/993))
