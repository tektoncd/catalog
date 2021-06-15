# YQ Task

The following task is used to replace a specific field in a yaml in the workspace.

## Installing the Task

```bash
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/yq/0.1/yq.yaml
```

## Parameters

- **file**: The file within the workspace to execute the in-place yq expression on.
- **expression**: The actual YQ expression to execute on this file. Checkout the excellent documentation at https://github.com/mikefarah/yq.
="$(params.new-image-sha)"'

## Workspaces

- **source** : The workspace containing files on which we want to do the replacement on a single file.

## Usage

For a real usage example checkout the tests directory of this task for an example on how this task can be used on a Github repository. This can be used together with other git actions to commit such changes towards a GitOps repository for example which is automatically reconciled towards your infrastructure.