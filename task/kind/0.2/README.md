# kind

This configures a kind (Kubernetes-in-Docker) environment to be ran in a Task.

See https://kind.sigs.k8s.io for more details.

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/task/kind/0.1/kind.yaml
```

## Workspaces

- **source**: A workspace that contains the working directory to share among
  Tasks.

## Parameters

| Name    | Description                                                                                                               |
| ------- | ------------------------------------------------------------------------------------------------------------------------- |
| image   | kind runtime image to use. Users must override this for their particular runtime environment needed for their kind tests. |
| command | command to run                                                                                                            |

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

This task sets up settings needed to run `kind` in a Tekton Task using
Docker-in-Docker. Because of the dependency on DinD, the Task runs in privileged
mode. Within the task users can create and interact with the `kind` clusters
like normal.

```yaml
name: kind
taskRef:
  name: kind
params:
  - name: command
    value: [<your command here>]
  - name: image
    value: <your image here>
workspaces:
  - name: source
    workspace: <workspace>
```

For a working example, see [tests/run.yaml](tests/run.yaml). This clones
[a sample repo](https://github.com/wlynch/tekton-kind) which includes a simple
script to create and interact with a kind cluster. `image` should point to an
image containing all runtime dependencies needed to run your test, including
kind. See https://github.com/wlynch/tekton-kind/blob/main/Dockerfile for a
sample Dockerfile to get started.
