# YQ Task

The following task is used to interface with the yq tool on any file in your workspace.

## Installing the Task

```bash
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/yq/0.4/yq.yaml
```

## Parameters

- **SCRIPT**: The yq script to execute. Can be multiple lines for complex tasks.
- **image**: The `yq` image to use. (_default:_ docker.io/mikefarah/yq:4.16.2@sha256:0d4f6e27bdcac7316f635acd524ab0eecc4ad50834b54d10322268650c7712cb)
- **files**: (deprecated, use SCRIPT instead) A list of files to execute the expression on. Needs to be relative to the source workspace. (_default:_ [])
- **expression**: (deprecated, use SCRIPT instead) The yq expression to apply. Can be used to replace yaml fields. (_default:_ "")

## Workspaces

- **source** : The workspace containing files on which we want to run yq commands.

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

For a real usage example checkout the [tests directory](https://github.com/tektoncd/catalog/tree/main/task/yq/0.4/tests) of this task for an example on how this task can be used on a Github repository. This can be used together with other git actions to commit such changes towards a GitOps repository for example which is automatically reconciled towards your infrastructure.