# Curl

This Task runs curl against provided URL and executes grep to validate the expected response.

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/curl-and-grep/curl-and-grep.yaml
```

## Inputs

### Parameters

* **url:**: URL to be curl'ed. 
* **text:**: text to grep (default: HTTP)

## Usage

This TaskRun runs the Task to curl https://tekton.dev and grep the response in order to find the "Tekton Pipelines" string.

```
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  name: tekton-dev-task-run-curl-and-grep-1
spec:
  inputs:
    params:
    - name: url
      value: https://tekton.dev
    - name: text
      value: Tekton Pipelines
  taskRef:
    name: curl-and-grep
```

This PipelineRun runs the Pipeline to build and deploy bookinfo-productpage on top of Knative and curl-and-grep the response in order to find the "The Comedy of Errors" string.

```
apiVersion: tekton.dev/v1alpha1
kind: PipelineResource
metadata:
  name: productpage-git
spec:
  type: git
  params:
    - name: revision
      value: master
    - name: url
      value: https://github.com/olegchorny/bookinfo-productpage
---
apiVersion: tekton.dev/v1alpha1
kind: PipelineResource
metadata:
  name: productpage-image
spec:
  type: image
  params:
    - name: url
      value: docker.io/ochorny/bookinfo-productpage
piVersion: tekton.dev/v1alpha1
kind: Pipeline
metadata:
  name: productpage-pipeline
spec:
  resources:
    - name: source-repo
      type: git
    - name: web-image
      type: image
  tasks:
    - name: build-kaniko
      taskRef:
        name: kaniko
      resources:
        inputs:
          - name: source
            resource: source-repo
        outputs:
          - name: image
            resource: web-image
    - name: deploy-web
      taskRef:
        name: deploy-using-kubectl
      resources:
        inputs:
          - name: source
            resource: source-repo
          - name: image
            resource: web-image
            from:
              - build-kaniko
      params:
        - name: path
          value: /workspace/source/ksvc.yaml
        - name: yqArg
          value: "-d0"
        - name: yamlPathToImage
          value: "spec.template.spec.containers[0].image"
    - name: curl-and-grep-web
      taskRef:
        name: curl-and-grep
      runAfter:
        - deploy-web
      params:
        - name: url
          value: productpage.bookinfo.svc.cluster.local/productpage
        - name: text
          value: The Comedy of Errors
---
apiVersion: tekton.dev/v1alpha1
kind: PipelineRun
metadata:
  name: productpage-pipeline-run-5
spec:
  trigger:
    type: manual
  pipelineRef:
    name: productpage-pipeline
  resources:
    - name: source-repo
      resourceRef:
        name: productpage-git
    - name: web-image
      resourceRef:
        name: productpage-image
```
