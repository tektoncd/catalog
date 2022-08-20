# Tekton Catalog Publish

This task publishes each Task in a Tekton catalog as [Tekton Bundles](https://tekton.dev/docs/pipelines/pipelines/#tekton-bundles).
The catalog must be structured as a [Tekton Catalog](https://github.com/tektoncd/catalog#catalog-structure).

Bundles are published to `$REGISTRY/$PATH/<task-name>:<task-version>` and, when `TAG` is provided, to
`$REGISTRY/$PATH/<task-name>:$TAG`. An example of extra tag could be the git sha of the catalog repo that
is being published. The task uses the `tkn bundle` command to publish, which is available
in `tkn` starting with version v0.18.0.

## Install the Task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/tekton-catalog-publish/0.1/raw
```

## Parameters

| name      | description                                 | default                               |
| --------- | ------------------------------------------- | ------------------------------------- |
| TKN_IMAGE | `tkn` CLI container image to run this task. | gcr.io/tekton-releases/dogfooding/tkn |
| REGISTRY  | The registry where bundles are published to |                                       |
| PATH      | The path in the registry                    | tekton/catalog/tasks                  |
| TAG       | An optional extra tag (optional)            | ""                                    |

## Workspaces

- **catalog**: A workspace with the catalog to be published.
- **dockerconfig**: An [optional workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md#using-workspaces-in-tasks)
  that allows providing a `.docker/config.json` file for tkn to access the container registry. The file should be placed at
  the root of the Workspace with name `config.json`.

## Platforms

The Task can be run on `linux/amd64`, `linux/s390x`, and `linux/ppc64le` platforms.

## Usage

1. Passing `REGISTRY` and catalog workspace:

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  generateName: tekton-catalog-publish-
spec:
  taskRef:
    name: tekton-catalog-publish
  workspaces:
    - name: source
      persistentVolumeClaim:
        claimName: my-source
  params:
     - name: REGISTRY
       value: icr.io
```

2. Passing `REGISTRY`, `PATH`, `TAG` and both workspaces

   1. Sample secret can be found [here](https://github.com/tektoncd/catalog/tree/main/task/tekton-catalog-publish/0.1/samples/secrets.yaml)

   2. Create `TaskRun`

 ```yaml
 apiVersion: tekton.dev/v1beta1
 kind: TaskRun
 metadata:
   generateName: tekton-catalog-publish-
 spec:
   taskRef:
     name: tekton-catalog-publish
   workspaces:
     - name: source
       persistentVolumeClaim:
         claimName: my-source
     - name: dockerconfig
       secret:
         secretName: regcred
   params:
     - name: REGISTRY
       value: icr.io
     - name: PATH
       value: tekton/mycatalog/tasks
     - name: TAG
       value: 49456927aef7e81a48a972db2bfd6e19a64d9a77
 ```
