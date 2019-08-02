# Knative with `kn`

This Task creates (or updates) a Knative service. It uses
[`kn`](https://github.com/knative/client) for that, and supports only creating
and updating services as of today.

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/kn/kn-create.yaml
```

## Inputs

### Parameters

* **service:**: The name of the service to create
* **force**: Whether to force creation, which overwrites existing services
  (_default_: false)

### Resources

* **image**: A `image`-type `PipelineResource` specifying the location of the
  service image to deploy.

## Usage

### Authorizing the Deployment

In order to create Knative services, you must first define a `ServiceAccount`
with permission to manage Knative services.

To create a `ServiceAccount` with these permissions, you can run:

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/kn/kn-deployer.yaml
```

### Running the Task

This TaskRun runs the Task to deploy the given image as a Knative service.

```
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  generateName: kn-create-
spec:
  serviceAccount: kn-deployer-account  # <-- run as the authorized SA

  taskRef:
    name: kn-create
  inputs:
    params:
    - name: service
      value: my-service
    resources:
    - name: image
      resourceSpec:
        type: image
        params:
        - name: url
          value: gcr.io/my-repo/my-service-image
```

Run this with:

```
kubectl create -f taskrun.yaml
```

In this example, the Image resource has to be built before hand, most
likely using a previous task.
