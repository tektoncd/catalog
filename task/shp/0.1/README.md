### Shipwright CLI

This task performs operations on Shipwright Builds using the CLI [`shp`](https://github.com/shipwright-io/cli).

## Install the Task

```bash
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/shp/0.1/shp.yaml
```


## Parameters

| name      | description                                 | default                                      |
| --------- | ------------------------------------------- | ---------------------------------------------|
| SHP_IMAGE | `shp` CLI container image to run this task. | `quay.io/shipwright/cli:0.12`   |
| ARGS      | The arguments to pass to the `shp` CLI.     | `--help`                                     |
| SCRIPT    | `shp` CLI script to execute                 | `shp \$@`                                    |

## Workspaces

- **kubeconfig**: An [optional workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md#using-workspaces-in-tasks) that allows you to provide a `.kube/config` file for `shp` to access the cluster. The file should be placed at the root of the Workspace with name `kubeconfig`.

## Platforms

The Task can be run on `linux/amd64`

## Usage

1. Passing only `ARGS`

```yaml
  tasks:
    - name: build
      taskRef:
        kind: Task
        name: shp
      params:
        - name: ARGS
            value:  
            - build 
            - run 
            - $(params.BUILD_NAME)
            - --follow

```

2. Passing `SCRIPT` and `ARGS` and `WORKSPACE`

Sample secret can be found [here](https://github.com/tektoncd/catalog/tree/main/task/shp/0.1/samples/kubeconfig-secret.yaml)

```yaml
  tasks:
    - name: build
      params:
        - name: SCRIPT
          value:  |
            shp build run $(params.BUILD_NAME) --follow
      taskRef:
        kind: Task
        name: shp
      workspaces:
        - name: kubeconfig
            secret:
                secretName: kubeconfig-secret
```
