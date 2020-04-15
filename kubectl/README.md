# Kubectl

This Task deploys (or delete) a Kubernates resource (pod). It uses
[`kubectl`](https://kubernetes.io/zh/docs/reference/kubectl/kubectl/) for that.

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/kubectl/kubectl-deploy.yaml
```

## Install ClusterRolebinding

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/kubectl/clusterrolebinding.yaml
```

## Inputs 

### Parameters

* **manifest:**: The content of the resource to deploy

## Usage

This TaskRun runs the Task to deploy the given Kubernetes resource.

```
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: kubectl-deploy-pod
spec:
  taskRef:
    name: kubectl-deploy-pod
  params:
  - name: manifest
    value: |
      apiVersion: v1
      kind: Pod
      metadata:
        name: myapp-pod
        labels:
          app: myapp
      spec:
        containers:
        - name: myapp-container
          image: docker
          command: ['sh', '-c', 'echo Hello Kubernetes! && sleep 3600']
```
