# Tekton Catalog Publish

This stepaction publishes each Task/StepAction in a Tekton catalog as [Tekton Bundles](https://tekton.dev/docs/pipelines/pipelines/#tekton-bundles).
The catalog must be structured as a [Tekton Catalog](https://github.com/tektoncd/catalog#catalog-structure).

Bundles are published to `$REGISTRY/$PATH/<task/stepaction-name>:<task/stepaction-version>` and, when `TAG` is provided, to
`$REGISTRY/$PATH/<task/stepaction-name>:$TAG`. An example of extra tag could be the git sha of the catalog repo that
is being published. The task uses the `tkn bundle` command to publish and support for decoding `StepActions`, which is available
in `tkn` starting with version `v0.34.0`.

Bundles are published with two OCI labels by default:
- `org.opencontainers.image.description`: The individual resource name, obtained from the containing folder name
- `org.opencontainers.image.version`: The individual resource version, obtained from the containing folder name and `$(params.TAG)`, if provided

## Install the StepAction

```bash
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/stepaction/tekton-catalog-publish/0.1/tekton-catalog-publish.yaml 
```

## Parameters

| name             | description                                                                    | default                               |
| ---------------- | ------------------------------------------------------------------------------ | ------------------------------------- |
| TKN_IMAGE        | `tkn` CLI container image to run this task.                                    | gcr.io/tekton-releases/dogfooding/tkn |
| TKN_ARGS         | Extra command line arguments passed as last to the `tkn` CLI.                  | "--label org.opencontainers.image.source=github.com/tektoncd/catalog" |
| REGISTRY         | The registry where bundles are published to                                    |                                       |
| RESOURCE         | The type of resouce being published: task or stepaction                        | task                                  |
| PATH             | The path in the registry                                                       | tekton/catalog/tasks                  |
| TAG              | An optional extra tag (optional)                                               | ""                                    |
| catalogPath      | The directory containing the catalog to be published                           |                                       |
| dockerconfigPath | The directory providing `.docker/config.json`.                                 | no-path                               |                                      
|                  | The file should be placed at the root of the Workspace with name `config.json` |                                       | 

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
  taskSpec:
    workspaces:
      - name: source
    steps:
    - name: publish
      ref:
        name: tekton-catalog-publish
      params:
        - name: catalogPath
          value: $(workspaces.source.path)
        - name: REGISTRY
          value: $(params.REGISTRY)
  workspaces:
    - name: source
      persistentVolumeClaim:
        claimName: my-source
  params:
     - name: REGISTRY
       value: icr.io
```

2. Passing `REGISTRY`, `PATH`, `TAG`, `TKN_ARGS` and both workspaces

   1. Sample secret can be found [here](https://github.com/tektoncd/catalog/tree/main/task/tekton-catalog-publish/0.1/samples/secrets.yaml)

   2. Create `TaskRun`

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  generateName: tekton-catalog-publish-
spec:
  taskSpec:
    workspaces:
      - name: source
      - name: dockerconfig
    steps:
    - name: publish
      ref:
        name: tekton-catalog-publish
      params:
        - name: catalogPath
          value: $(workspaces.source.path)
        - name: dockerconfigPath
          value: $(workspaces.dockerconfig.path)
        - name: REGISTRY
          value: $(params.REGISTRY)
        - name: PATH
          value: $(params.PATH)
        - name: TAG
          value: $(params.TAG)
        - name: TKN_ARGS
          value: $(params.TKN_ARGS)
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
    - name: TKN_ARGS
      value: "--label org.opencontainers.image.source=github.com/tektoncd/catalog"
```
