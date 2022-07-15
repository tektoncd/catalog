# YQ Task

The following task is used to replace a specific field in a yaml in the workspace.

## Installing the Task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/yq/0.3/raw
```

## Parameters

- **files**: A list of files within the workspace to execute the in-place yq expression on.
- **expression**: The actual YQ expression to execute on this file. Checkout the excellent documentation at https://github.com/mikefarah/yq.
="$(params.new-image-sha)"'
- **image**: The `yq` image to use. (_default:_ docker.io/mikefarah/yq:4.16.2@sha256:0d4f6e27bdcac7316f635acd524ab0eecc4ad50834b54d10322268650c7712cb)
## Workspaces

- **source** : The workspace containing files on which we want to do the replacement on a single file.

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

For a real usage example checkout the [tests directory](https://github.com/tektoncd/catalog/tree/main/task/yq/0.3/tests) of this task for an example on how this task can be used on a Github repository. This can be used together with other git actions to commit such changes towards a GitOps repository for example which is automatically reconciled towards your infrastructure.