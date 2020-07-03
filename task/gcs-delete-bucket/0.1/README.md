# Google Cloud Storage Tasks

These `Tasks` are for copying to and from GCS buckets from Pipelines.

These `Tasks` do a similar job to the `GCS` `PipelineResource` and
are intended as its replacement. This is part of our plan to [offer replacement
`Tasks` for Pipeline Resources](https://github.com/tektoncd/catalog/issues/95)
as well as
[document those replacements](https://github.com/tektoncd/pipeline/issues/1369).


## `gcs-delete-bucket`

A `Task` that deletes a GCS bucket.

### Workspaces

* **credentials**: A workspace that contains a service account key as a JSON file.
    This workspace should be populated from a Secret in your TaskRuns and PipelineRuns.

### Parameters

* **bucketName**: The name of the bucket (including "gs://") to create. (_required_)
* **serviceAccountPath**: The path to the service account credential file in your credentials workspace. (_default_: "service_account.json")



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