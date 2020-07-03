# Google Cloud Storage Tasks

These `Tasks` are for copying to and from GCS buckets from Pipelines.

These `Tasks` do a similar job to the `GCS` `PipelineResource` and
are intended as its replacement. This is part of our plan to [offer replacement
`Tasks` for Pipeline Resources](https://github.com/tektoncd/catalog/issues/95)
as well as
[document those replacements](https://github.com/tektoncd/pipeline/issues/1369).



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