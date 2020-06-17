# `buildid`

Given a base version, this task generates a unique build id by appending the base-version to the current timestamp.

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/buildid/task.yaml
```

## Parameters

* **base-version**: The base version to use in the generated build id.  _default_: `["1.0"]`

## Usage

### Include the task inside a taskrun
In this example, we will demonstrate how to use the task to generate the build id by including it in a taskrun definition called `taskrun.yaml`:

```
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: generate-build-id-run
spec:
  params:
    - name: base-version
      value: "2.3.1"
  taskRef:
    name: generate-build-id
```

As can be seen from the example, the default `base-version` is being overridden by providing a new `base-version` value of `2.3.1` as input param to the task.

The taskrun definition is then applied by installing it in Kubernetes cluster as `kubectl apply -f taskrun.yaml`.
Logs from the executed task are then retrieved using `tkn taskrun logs generate-build-id-run`:

```
#\> tkn taskrun logs generate-build-id-run
[get-timestamp] Current Timestamp: 20200617-180133
[get-timestamp] 20200617-180133

[get-buildid] 2.3.1-20200617-180133

```

### Use the generated build id in another task in a pipeline definition
In this example, we will demonstrate how the generated build id can be used by another task by including them inside a pipeline definition.

In the following example two tasks are included in a pipeline definition called `pipeline.yaml`

```
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: pipeline-demo-generated-build-id
spec:
  params:
    - name: service-version
      type: string
      default: "3.1.1"
  tasks:
    - name: get-build-id
      taskRef:
        name: generate-build-id
      params:  
        - name: base-version
          value: $(params.service-version)       
    - name: build-api
      taskRef:
        name: build-service-api
      params:
        - name: build-id
          value: "$(tasks.get-build-id.results.build-id)"
```
As can be seen from the example the first task generates the build id while the second task consumes the generated build id.
In the task to generate the build id, we override the default value of `base-version` using the value of the `service-version` pipeline parameter that has currentluy been set to a default value of 3.1.1.
In the task to build the service api, we then pass the generated build from the first task as its input param called `build-id`.
For the sake of completeness, here is what the task to build the service api (`build-service-api.yaml`) looks like:

```
apiVersion: tekton.dev/v1betal
kind: Task
metadata:
  name: build-service-api
spec:
  params:
    - name: build-id
      description: ID of the current build
      type: string                          
  steps:
    - name: display-buildid
      image: bash:latest
      script: |
        #!/usr/bin/env bash
        echo "Provided Build ID: $(inputs.params.build-id)"
```

As can be seen above, this task accepts a build id as its input and displays it in its one and only step.

The task to build the service api and pipeline are then installed using `kubectl apply -f build-service-api.yaml` and `kubectl apply -f pipeline.yaml`.
Once installed the pipeline is started using `tkn pipeline start pipeline-demo-generated-build-id`.
Logs from the executed pipeline demonstrate that the first task generated a build id while the second task consumed it:

```
#\> tkn pipeline start pipeline-demo-generated-build-id
? Value for param `service-version` of type `string`? (Default is `3.1.1`) 3.1.1
Pipelinerun started: pipeline-demo-generated-build-id-run-g7tgw

In order to track the pipelinerun progress run:
tkn pipelinerun logs pipeline-demo-generated-build-id-run-g7tgw -f -n default

#\> tkn pipelinerun logs pipeline-demo-generated-build-id-run-g7tgw
[get-build-id : get-timestamp] Current Timestamp: 20200617-181338
[get-build-id : get-timestamp] 20200617-181338

[get-build-id : get-buildid] 3.1.1-20200617-181338

[build-api : display-buildid] Provided Build ID: 3.1.1-20200617-181338
```