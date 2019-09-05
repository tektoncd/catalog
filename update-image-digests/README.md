# Update Image Digests

This Task updates all image resources that has digests exported built by a predecessor task in the same pipeline run.

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/update-image-digests/update-image-digests.yaml
```

## Inputs

### Parameters

* **pipelineTask**: The name of the task that exports image digests in the pipeline.

## Usage

### Authorizing the Deployment

In order to retrieve digests and update image resources, you must first define a `ServiceAccount`
with permission to get and patch resources.

To create a `ServiceAccount` with these permissions, you can run:

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/update-image-digests/image-digest-updater.yaml
```

### Using the Task in a Pipeline

The following Pipeline uses this Task to update the digest of an image resource outputted by Task
`build`, so `test` can find the correct image to run tests.
```
apiVersion: tekton.dev/v1alpha1
kind: Pipeline
metadata:
  name: build-and-test
spec:
  resources:
  - name: git-source
    type: git
  - name: built-image
    type: image
  tasks:
  - name: build
    resources:
      inputs:
      - name: git-source
        resource: git-source
      outputs:
      - name: built-image
        resource: built-image
    taskRef:
      name: source-to-image
  - name: update-digest
    params:
    - name: pipelineTask
      value: build
    runAfter:
    - build
    taskRef:
      name: update-image-digests
  - name: test
    resources:
      inputs:
      - from:
        - build
        name: built-image
        resource: built-image
    runAfter:
    - update-digest
    taskRef:
      name: run-test-binary
```

### Runtime Assumptions

This Task relies on the following implementation details of Tekton pipeline:
* The pod running this Task has the `tekton.dev/pipelineRun` label set to the name of the
  PipelineRun this pod belongs to, which is true if this Task is in a Pipeline.
* The TaskRun of the Task is created after its predecessor Task finishes. It uses the name of the
  PipelineRun and the `pipelineTask` parameter to uniquely identify the predecessor's TaskRun and
  gets the image digests from the status of the predecessor.
* The TaskRuns of all successor Tasks are created after this Task finishes, so the string
  interpolation can find the updated digests.
* The entrypoint image provides `sh`, `cat`, `egrep` and `xargs`. These utility binaries don't exist
  in the `lachlanevenson/k8s-kubectl` and `stedolan/jq` images used by this Task.
