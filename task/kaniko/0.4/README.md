# Kaniko

This Task builds source into a container image using Google's
[`kaniko`](https://github.com/GoogleCloudPlatform/kaniko) tool.

>kaniko doesn't depend on a Docker daemon and executes each command within a
>Dockerfile completely in userspace.  This enables building container images in
>environments that can't easily or securely run a Docker daemon, such as a
>standard Kubernetes cluster.
> - [Kaniko website](https://github.com/GoogleCloudPlatform/kaniko)

kaniko is meant to be run as an image, `gcr.io/kaniko-project/executor:v1.5.1`. This
makes it a perfect tool to be part of Tekton.

## Changelog

- Replace `ServiceAccount` based authentication with a workspace based one. Tekton's built-in auth
  [can be disabled](https://github.com/tektoncd/pipeline/blob/main/docs/auth.md#disabling-tektons-built-in-auth),
  it can be hard to debug and it might not work for all type of credentials. Workspaces are available to all
  deployments, and can be bound to both secrets and PVCs.

## Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/kaniko/0.4/raw
```

## Parameters

* **IMAGE**: The name (reference) of the image to build.
* **DOCKERFILE**: The path to the `Dockerfile` to execute (_default:_ `./Dockerfile`)
* **CONTEXT**: The build context used by Kaniko (_default:_ `./`)
* **EXTRA_ARGS**: Additional args to pass to the Kaniko executor.
* **BUILDER_IMAGE**: The Kaniko executor image to use (_default:_ `gcr.io/kaniko-project/executor:v1.5.1`)
* **JQ_IMAGE**: The image to parse digest after the image build (_default:_ `docker.io/stedolan/jq:latest`)

## Workspaces

* **source**: A [Workspace](https://github.com/tektoncd/pipeline/blob/master/docs/workspaces.md) containing the source to build.
* **dockerconfig**: An optional [Workspace](https://github.com/tektoncd/pipeline/blob/master/docs/workspaces.md) containing a Docker `config.json`

## Results

* **IMAGE-DIGEST**: The digest of the image just built.

## Authentication to a Container Registry

kaniko builds an image and pushes it to the destination defined as a parameter.
In order to properly authenticate to the remote container registry, it needs to
have the proper credentials. This can achieved by using a workspace that contains
the docker `config.json`.

When using a workspace, the workspace shall be bound to a secret that embeds the
configuration file in a key called `config.json`.

## Platforms

The Task can be run on `linux/amd64`, `linux/s390x` and `linux/ppc64le` platforms.

For `linux/s390x` platform specify `BUILDER_IMAGE` parameter with `gcr.io/kaniko-project/executor:s390x-9ed158c1f63a059cde4fd5f8b95af51d452d9aa7`
value and `JQ_IMAGE` parameter with `ibmcom/jq-s390x:latest` value  in TaskRun or PipelineRun.

For `linux/ppc64le` platform specify `JQ_IMAGE` parameter with `ibmcom/jq-ppc64le:latest` value  in TaskRun or PipelineRun.

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
