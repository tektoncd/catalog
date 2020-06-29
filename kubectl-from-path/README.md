# Kubectl

This task uses kubectl to do a specific action (e.g create, apply, delete) from a certain path
[`kubectl`](https://kubernetes.io/en/docs/reference/kubectl/kubectl/) for this.

Note that you'll probably want to use this in combination with a cloned GitHub repository, for example with:

```
  - name: deploy
    runAfter: [build]
    taskRef: 
      name: kubectl
    resources: 
      inputs:
      - name: git-source
        resource: git-source 
      - name: image-out
        resource: docker-image
```

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/kubectl-from-path/kubectl.yaml
```
