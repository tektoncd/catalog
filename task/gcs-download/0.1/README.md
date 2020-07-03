# Google Cloud Storage Tasks

These `Tasks` are for copying to and from GCS buckets from Pipelines.

These `Tasks` do a similar job to the `GCS` `PipelineResource` and
are intended as its replacement. This is part of our plan to [offer replacement
`Tasks` for Pipeline Resources](https://github.com/tektoncd/catalog/issues/95)
as well as
[document those replacements](https://github.com/tektoncd/pipeline/issues/1369).

## `gcs-download`

A `Task` that fetches files or directories from a GCS bucket and puts them
on a Workspace.

### Workspaces

* **credentials**: A workspace that contains a service account key as a JSON file.
    This workspace should be populated from a Secret in your TaskRuns and PipelineRuns.
* **output**: A workspace for this Task to copy the files from GCS in to.

### Parameters

* **path**: The path to the file or directory that will be written to the output workspace. (_required_)
* **location**: The address, including "gs://", of the bucket you'd like to copy from. (_required_)
* **typeDir**: Set this to "true" if the object you are copying is a directory. (_default_: "false")
* **serviceAccountPath**: The path to the service account credential file in your credentials workspace. (_default_: "service\_account.json")


## Usage

### `gcs-download`

This pipeline uses the gcs-download Task to fetch a directory.

```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: cat-file
spec:
  workspaces:
  - name: source
    mountPath: /source
  params:
  - name: filePath
    description: Path to file inside "source" to cat.
    default: "README.md"
  steps:
  - name: cat-readme
    image: ubuntu
    script: cat "$(workspaces.source.path)/$(params.filePath)"
---
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: cat-file
spec:
  workspaces:
  - name: gcs-credentials
    description: A secret containing a gcloud service account key JSON file.
  - name: shared-workspace
    description: The GCS location will be copied into this workspace.
  tasks:
  - name: copy-files
    taskRef:
      name: gcs-download
    workspaces:
    - name: credentials
      workspace: gcs-credentials
    - name: output
      workspace: shared-workspace
    params:
    - name: path
      value: foo
    - name: location
      value: gs://this-is-not-a-real-bucket
    - name: typeDir
      value: "true"
  - name: print-readme
    taskRef:
      name: cat-readme
    runAfter:
    - copy-files # required to ensure copy occurs before cat
    workspaces:
    - name: source
      workspace: shared-workspace
    params:
    - name: filePath
      value: "foo/test.txt"
```

This pipeline can be used as the following `PipelineRun` does.

```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: workspace-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
---
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: cat-file-pr
spec:
  pipelineRef:
    name: cat-file
  workspaces:
  - name: gcs-credentials
    secret:
      secretName: my-gcs-credentials
      defaultMode: 0400
  - name: shared-workspace
    persistentVolumeClaim:
      claimName: workspace-pvc
```