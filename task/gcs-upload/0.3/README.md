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
* **deleteExtraFiles**: When "true", delete extra files under location not found under path. (_default_: "false")
  NOTE: this option can delete data quickly if you specify the wrong source/destination combination. "BE CAREFUL WHEN USING THIS OPTION!".

  NOTE: this option is implemented via "gsutil rsync". If the target bucket
  contains a large number of files, it may take a long time for gsutil to
  fetch the remote metadata for sync.

  NOTE: setting this option to "true" is not compatible with replaceExistingFiles="false"
* **replaceExistingFiles**: When "false", files that already exists are skipped. (_default_: "true")
  NOTE: setting this option to "false" is not compatible with deleteExtraFiles="true"
* **serviceAccountPath**: The path to the service account credential file in your credentials workspace. (_default_: "service\_account.json")

## Platforms

The Task can be run on `linux/amd64` platform.

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
