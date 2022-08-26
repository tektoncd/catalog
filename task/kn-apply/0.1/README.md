# Knative with `kn`

This task deploys a given image to a Knative Service using
[`kn`](https://github.com/knative/client) command line interface.

## Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/kn-apply/0.1/raw
```

## Parameters

* **KN_IMAGE**: `kn` CLI container image to run this task.

  _default_: `gcr.io/knative-releases/knative.dev/client/cmd/kn:latest`

  You can use nightly build of the `kn` CLI using
  `gcr.io/knative-nightly/knative.dev/client/cmd/kn`.

* **SERVICE**: Name of the Knative Service to deploy the given image to.
  The service will be created or updated if it exists.

* **IMAGE**: Container image to run.

## Platforms

The Task can be run on `linux/amd64`, `linux/s390x`, `linux/arm64` and `linux/ppc64le` platforms.

## Usage

### Authorizing the Deployment

In order to create Knative services, you must first define a `ServiceAccount`
with permission to manage Knative resources.

To create a `ServiceAccount` with these permissions, you can run:

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/kn-apply/0.1/support/kn-deployer.yaml
```

The service account is being created for 'default' namespace, please edit the
file before applying if you are operating in different namespace.

### Running the Task

- Following TaskRun deploys a Knative Service using given image.

```
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  generateName: kn-apply-
spec:
  serviceAccountName: kn-deployer-account  # <-- run as the authorized SA
  taskRef:
    name: kn-apply
  params:
  - name: SERVICE
    value: "hello"
  - name: IMAGE
    value: "gcr.io/knative-samples/helloworld-go:latest"
```

Run this with:

```
kubectl create -f kn-apply-taskrun.yaml
```

For the first run, this will create the service 'hello' and any subsequent
runs will update the 'hello' service based on your image updates.
