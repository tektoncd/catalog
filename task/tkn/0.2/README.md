# tkn

This task performs operations on Tekton resources using
[`tkn`](https://github.com/tektoncd/cli).

## Install the Task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/tkn/0.2/raw
```

## Parameters

| name      | description                                 | default                               |
| --------- | ------------------------------------------- | ------------------------------------- |
| TKN_IMAGE | `tkn` CLI container image to run this task. | gcr.io/tekton-releases/dogfooding/tkn |
| ARGS      | The arguments to pass to the `tkn` CLI.     | --help                                |
| SCRIPT    | `tkn` CLI script to execute                 | tkn \$@                               |

## Workspaces

- **kubeconfig**: An [optional workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md#using-workspaces-in-tasks) that allows you to provide a `.kube/config` file for `tkn` to access the cluster. The file should be placed at the root of the Workspace with name `kubeconfig`.

## Platforms

The Task can be run on `linux/amd64`, `linux/s390x` and `linux/ppc64le` platforms.

## Usage

1. Passing only `ARGS`

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: tkn-run
spec:
  taskRef:
    name: tkn
  params:
    - name: ARGS
      value:
        - task
        - list
```

2. Passing `SCRIPT` and `ARGS` and `WORKSPACE`

   1. Sample secret can be found [here](https://github.com/tektoncd/catalog/tree/main/task/tkn/0.2/samples/secrets.yaml)

   2. Create `TaskRun`

   ```yaml
   apiVersion: tekton.dev/v1beta1
   kind: TaskRun
   metadata:
     name: tkn-run
   spec:
     taskRef:
       name: tkn
     workspaces:
       - name: kubeconfig
         secret:
           secretName: kubeconfig
     params:
       - name: SCRIPT
         value: |
           tkn task start $1
           tkn taskrun list
           tkn task logs $1 -f
       - name: ARGS
         value:
           - taskRunName
   ```
