# 3Scale Toolbox Import

This Task can be used to run the 3scale toolbox and  import to your 3scale API directly from a local OpenAPI spec compliant file or a remote URL.

## Install the Task

```bash
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/3scale-toolbox-import/0.1/3scale-toolbox-import.yaml
```

## Parameters

- **CONTEXT_DIR**: The path to the source
- **PATH_OPENAPI**: The path to openapi file or url to be imported
- **DESTINATION**: The name of 3scale target instance.
- **PRIVATE_BASE_URL**: The URL of the API Backend, custom private base URL.
- **TARGET_SYSTEM_NAME**: The Target system name.
## Workspaces

- **source**: `PersistentVolumeClaim`-type so that volume can be shared among `git-clone` and `import` task

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: 3scale-source-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
```

## Platforms

The Task can be run on `linux/amd64`,`linux/s390x`,`linux/ppc64le` and `linux/arm64` platform.

## Usage

This Pipeline and PipelineRun runs a 3scale toolbox import openapi

### With .3scalerc.yaml file
The remote address can be used from .3scalerc.yaml file, need to create a configMap from .3scalerc.yaml file, it could be generated with the command below.
$ 3scale remote add https://{ACCESS_KEY}@{3SCALE_ADMIN}-admin.{DOMAIN_NAME}

Create configMap from file
$ oc create cm toolbox-config \
  --from-file=.3scalerc.yaml=$HOME/.3scalerc.yaml

```yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: toolbox-config
data:
  .3scalerc.yaml: |
    ---
    :remotes:
      3scale28:
        :authentication: <ACCESS_KEY>
        :endpoint: <{3SCALE_ADMIN}-admin.{DOMAIN_NAME}>
```

### With Defaults

```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: pipeline-import-openapi-sample
spec:
  tasks:
    - name: 3scale-toolbox-import
      params:
        - name: CONTEXT_DIR
          value: shared-workspace
        - name: PATH_OPENAPI
          value: swagger.json
        - name: PRIVATE_BASE_URL
          value: 'http://sample.svc.cluster.local:8080'
        - name: TARGET_SYSTEM_NAME
          value: sample_api
        - name: DESTINATION
          value: 3scale28
      runAfter:
        - git-clone
      taskRef:
        kind: Task
        name: 3scale-toolbox-import
      workspaces:
        - name: output
          workspace: shared-workspace
    - name: git-clone
      params:
        - name: url
          value: 'https://github.com/rafamqrs/camel-quarkus-openapi.git'
        - name: revision
          value: main
        - name: submodules
          value: 'true'
        - name: depth
          value: '1'
        - name: sslVerify
          value: 'true'
        - name: subdirectory
          value: shared-workspace
        - name: deleteExisting
          value: 'true'
        - name: verbose
          value: 'true'
        - name: gitInitImage
          value: >-
            registry.redhat.io/openshift-pipelines/pipelines-git-init-rhel8@sha256:afc5d3f9efe26c7042635d43b8ffd09d67936e3d0b6b901dc08a33e20313d361
      taskRef:
        kind: ClusterTask
        name: git-clone
      workspaces:
        - name: output
          workspace: shared-workspace
  workspaces:
    - name: shared-workspace
---
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: pipeline-import-openapi-sample-q6paqc
  labels:
    tekton.dev/pipeline: pipeline-import-openapi-sample
spec:
  pipelineRef:
    name: pipeline-import-openapi-sample
  workspaces:
    - name: shared-workspace
      persistentVolumeClaim:
        claimName: 3scale-pipeline-pvc
```

---