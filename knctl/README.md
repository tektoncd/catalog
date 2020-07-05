# Knative with knctl

This Task deploys (or update) a Knative service. It uses
[`knctl`](https://github.com/cppforlife/knctl) for that, and supports
only the `deploy` subcommand as of today.

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/knctl/knctl-deploy.yaml
```

## Parameters

* **service:**: The name of the service to deploy

## Resources

### Inputs

* **image**: A `image`-type `PipelineResource` specifying the location of the
  service image to deploy.

## Usage

This TaskRun runs the Task to deploy the given image as a Knative service.

```
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: knctl-deploy-my-service
spec:
  taskRef:
    name: knctl-deploy
  params:
  - name: service
    value: my-service
  resources:
    inputs:
    - name: image
      resourceSpec:
        type: image
        params:
        - name: url
          value: gcr.io/my-repo/my-service-image
```

In this example, the Image resource has to be built before hand, most
likely using a previous task.
