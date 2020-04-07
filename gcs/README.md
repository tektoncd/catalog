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

## `gcs-upload`

A `Task` that uploads files or directories from a Workspace to a GCS bucket.

### Workspaces

* **credentials**: A workspace that contains a service account key as a JSON file.
    This workspace should be populated from a Secret in your TaskRuns and PipelineRuns.
* **source**: A workspace where files will be uploaded from.

### Parameters

* **path**: The path to files or directories relative to the source workspace that you'd like to upload. (_required_)
* **location**: The address (including "gs://") where you'd like to upload files to. (_required_)
* **serviceAccountPath**: The path to the service account credential file in your credentials workspace. (_default_: "service\_account.json")

## `gcs-create-bucket`

A `Task` that creates a new GCS bucket.

### Workspaces

* **credentials**: A workspace that contains a service account key as a JSON file.
    This workspace should be populated from a Secret in your TaskRuns and PipelineRuns.

### Parameters

* **bucketName**: The name of the bucket (including "gs://") to create. (_required_)
* **project**: The project with which your bucket will be associated. (_required_)
* **storageClass**: The storage class for the new bucket. STANDARD, NEARLINE, COLDLINE, or ARCHIVE. (_default_: "STANDARD")
* **region**: The region, dual-region, or multi-region for the new bucket. (_default_: "")
* **uniformAccess**: Set this to "true" if the bucket should be created with bucket-level permissions instead of Access Control Lists. (_default_: "false")
* **serviceAccountPath**: The path to the service account credential file in your credentials workspace. (_default_: "service\_account.json")

## `gcs-delete-bucket`

A `Task` that deletes a GCS bucket.

### Workspaces

* **credentials**: A workspace that contains a service account key as a JSON file.
    This workspace should be populated from a Secret in your TaskRuns and PipelineRuns.

### Parameters

* **bucketName**: The name of the bucket (including "gs://") to create. (_required_)
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

### `gcs-upload`

This TaskRun uses the gcs-upload Task to upload a file from a ConfigMap.

```yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: test-input-data
data:
  test_file.txt: "Hello, world!"
---
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: upload-configmap-file-to-gcs
spec:
  taskRef:
    name: gcs-upload
  workspaces:
  - name: credentials
    secret:
      secretName: my-gcs-credentials
      defaultMode: 0400
  - name: source
    configMap:
      name: test-input-data
```

### `gcs-create-bucket`

This TaskRun uses the gcs-create-bucket Task to create a new bucket in the singapore region.

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: test-create-a-bucket
spec:
  taskRef:
    name: gcs-create-bucket
  workspaces:
  - name: credentials
    secret:
      secretName: my-gcs-credentials
      defaultMode: 0400
  params:
  - name: bucketName
    value: gs://my-fancy-new-test-bucket-12345
  - name: project
    value: my-test-project
  - name: region
    value: ASIA-SOUTHEAST1
```

### `gcs-delete-bucket`

This TaskRun uses the gcs-delete-bucket Task to delete the bucket created in the previous example.

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: test-delete-a-bucket
spec:
  taskRef:
    name: gcs-delete-bucket
  workspaces:
  - name: credentials
    secret:
      secretName: my-gcs-credentials
      defaultMode: 0400
  params:
  - name: bucketName
    value: gs://my-fancy-new-test-bucket-12345
```
