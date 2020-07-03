# Google Cloud Storage Tasks

These `Tasks` are for copying to and from GCS buckets from Pipelines.

These `Tasks` do a similar job to the `GCS` `PipelineResource` and
are intended as its replacement. This is part of our plan to [offer replacement
`Tasks` for Pipeline Resources](https://github.com/tektoncd/catalog/issues/95)
as well as
[document those replacements](https://github.com/tektoncd/pipeline/issues/1369).


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


## Usage


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