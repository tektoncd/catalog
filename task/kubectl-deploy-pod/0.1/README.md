# Kubectl

This Task deploys (or delete) a Kubernetes resource (pod). It uses
[`kubectl`](https://kubernetes.io/zh/docs/reference/kubectl/kubectl/) for that.

## Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/kubectl-deploy-pod/0.1/raw
```

## Install ClusterRole

**CAUTION:** The `clusterrole.yaml` is just a sample, should be modified based on real requirements to avoid potential security issues.

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/kubectl-deploy-pod/0.1/support/clusterrole.yaml
```

## Install ClusterRolebinding

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/kubectl-deploy-pod/0.1/support/clusterrolebinding.yaml
```

## Inputs

### Parameters

- **action**: The action to perform to the resource, support `get`, `create`, `apply`, `delete`, `replace`, `patch`.
- **manifest**: The content of the resource to deploy.
- **success-condition/failure-condition**: SuccessCondition and failureCondition are optional expressions which are evaluated upon every update of the resource. If failureCondition is ever evaluated to true, the step is considered failed. Likewise, if successCondition is ever evaluated to true the step is considered successful. It uses kubernetes label selection syntax and can be applied against any field of the resource (not just labels). Multiple AND conditions can be represented by comma delimited expressions. For more details, see: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/.
- **merge-strategy**: The strategy used to merge a patch, defaults to `strategic`, supported `strategic`, `merge` and `json`.
- **output**: Extracted from fields of the resource, only support jsonpath. Should define as a `yaml` array(array even if only one item):

```yaml
- name: output
  value: |
    - name: job-name
      valueFrom: '{.metadata.name}'
    - name: job-namespace
      valueFrom: '{.metadata.namespace}'
```

The extracted value will be write to`/tekton/results/$(name)`.

- **set-ownerreference**: Set the `ownerReferences` for the resource as pod of `step`, default to false.

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

This TaskRun runs the Task to deploy the given Kubernetes resource.

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: kubectl-deploy-pod
spec:
  taskRef:
    name: kubectl-deploy-pod
  params:
    - name: action
      value: create
    - name: success-condition
      value: status.phase == Running
    - name: failure-condition
      value: status.phase in (Failed, Error)
    - name: output
      value: |
        - name: job-name
          valueFrom: '{.metadata.name}'
        - name: job-namespace
          valueFrom: '{.metadata.namespace}'
    - name: set-ownerreference
      value: "true"
    - name: manifest
      value: |
        apiVersion: v1
        kind: Pod
        metadata:
          generateName: myapp-pod-
          labels:
            app: myapp
        spec:
          containers:
          - name: myapp-container
            image: docker
            command: ['sh', '-c', 'echo Hello Kubernetes! && sleep 30']
```
