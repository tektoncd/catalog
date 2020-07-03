# Google Cloud Storage Tasks

These `Tasks` are for copying to and from GCS buckets from Pipelines.

These `Tasks` do a similar job to the `GCS` `PipelineResource` and
are intended as its replacement. This is part of our plan to [offer replacement
`Tasks` for Pipeline Resources](https://github.com/tektoncd/catalog/issues/95)
as well as
[document those replacements](https://github.com/tektoncd/pipeline/issues/1369).

## `gcs-generic`

A `Task` that allows users customize and extend the gsutil command line based on their needs.

### Workspaces

* **credentials**: A workspace that contains a service account key as a JSON file.
    This workspace should be populated from a Secret in your TaskRuns and PipelineRuns.

### Parameters

* **command**: The command line that you would like to enter to the workspace. (_required_)
* **options**: The extended command line that you would like to enter. (_required_)
* **serviceAccountPath**: The path to the service account credential file in your credentials workspace. (_default_: "service_account.json")
* **image**: The google cloud image that will be used in steps. (_default_: "google/cloud-sdk")

## Usage


### `gcs-generic`

This TaskRun uses the gcs-generic Task to list all the objects in the directory.

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: gcs-generic-taskrun
spec:
  taskRef:
    name: gcs-generic
  workspaces:
  - name: credentials
    secret:
      secretName: my-gcs-credentials
  params:
  - name: command
    value: ls
  - name: options
    value:
     - "-l"
     - "gs://tekton-releases"
```