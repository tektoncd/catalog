# Knative with `kn`

This Task performs operations on Knative resources (services, revisions, routes) using
[`kn`](https://github.com/knative/client) CLI.

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/kn/kn.yaml
```

## Parameters

* **kn-image**: `kn` CLI container image to run this task.

  _default_: `gcr.io/knative-releases/knative.dev/client/cmd/kn:v0.10.0`

  You can use nightly build of the `kn` CLI using
  `gcr.io/knative-nightly/knative.dev/client/cmd/kn`.


* **ARGS**: The arguments to pass to `kn` CLI.  _default_: `["help"]`

## Resources

### Inputs

* **image**: An `image`-type `PipelineResource` specifying the location of the
  container image to deploy for Knative Service.

  User provides the `image`-type resource to kn CLI in parameter `ARGS` as an
  element of the array, for e.g. `"--image=$(inputs.resources.image.url)"`.

## Usage

### Authorizing the Deployment

In order to create Knative services, you must first define a `ServiceAccount`
with permission to manage Knative resources.

To create a `ServiceAccount` with these permissions, you can run:

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/kn/kn-deployer.yaml
```

### Running the Task

Let's take examples of creating and updating a Knative Service using `kn` task.

1. Following TaskRun runs the Task to create a Knative Service using given image.

```
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  generateName: kn-create-
spec:
  serviceAccountName: kn-deployer-account  # <-- run as the authorized SA
  taskRef:
    name: kn
  resources:
    inputs:
    - name: image
      resourceSpec:
        type: image
        params:
        - name: url
          value: gcr.io/knative-samples/helloworld-go
  params:
  - name: ARGS
    value:
    - "service"
    - "create"
    - "hello"
    - "--force"
    - "--image=$(inputs.resources.image.url)"
```

Run this with:

```
kubectl create -f kn-create-taskrun.yaml
```

2. Following TaskRun runs the Task to update a Knative Service using given image or parameters.

```
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  generateName: kn-update-
spec:
  serviceAccountName: kn-deployer-account  # <-- run as the authorized SA
  taskRef:
    name: kn
  resources:
    inputs:
    - name: image
      resourceSpec:
        type: image
        params:
        - name: url
          value: gcr.io/knative-samples/helloworld-go
  params:
  - name: ARGS
    value:
    - "service"
    - "update"
    - "hello"
    - "--image=$(inputs.resources.image.url)"
    - "--env=TARGET=Tekton"
```

Run this with:

```
kubectl create -f kn-update-taskrun.yaml
```

In these examples, the `image` resource can be built before hand, most
likely using a previous task.

## Pipeline
Checkout the sample Pipelines for building your git source and deploying
as Knative Service [here](./knative-dockerfile-deploy/README.md).
