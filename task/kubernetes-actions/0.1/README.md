# kubernetes actions

This is a generic task used to perform kubernetes actions such as `kubectl get deployment` or `kubectl create -f filename.yaml`. For more commands [see](https://kubernetes.io/docs/reference/kubectl/overview/).

## Install the task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/task/kubernetes-actions/0.1/kubernetes-actions.yaml
```

## Inputs

### Parameters

- **script**: script of `kubectl` commands to execute e.g. `kubectl get pod $1 -0 yaml`. This will take the first value of ARGS as pod name (_default_: `kubectl $@`)
- **args**: args to execute which are appended to `kubectl` e.g. `start-build myapp` (_default_: `help`)
- **image**: Default image being `gcr.io/cloud-builders/kubectl`. If somebody wants to use their own image then they can provide it as a part of params. For example an image avilable is `lachlanevenson/k8s-kubectl`

### Workspaces

- **kubeconfig-dir**: If you want to deploy you application to another cluster then you can mount your `kubeconfig` file via this `workspace`. (Default: _emptyDir:{}_ in case `kubeconfig` is not mounted)
- **manifest-dir**: Manifest files can be provided via the workspaces.(Default: _emptyDir:{}_ in case no manifest is provided)

## Usage

In case no manifests are mounted

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: kubectl-run
spec:
  taskRef:
    name: kubectl-actions
  params:
    - name: SCRIPT
      value: |
        kubectl get pods 
        echo "-----------"
        kubectl get deploy
  workspaces:
    - name: kubeconfig-dir
      emptyDir: {}
    - name: manifest-dir
      emptyDir: {}
```

In case manifest is present on `GitHub` :

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: kubectl-run
spec:
  taskRef:
    name: kubectl-actions
  params:
    - name: script
      value: |
        kubectl apply -f https://raw.githubusercontent.com/vinamra28/social-client/master/k8s/deployment.yaml
        ----------
        kubectl get deployment
  workspaces:
    - name: kubeconfig-dir
      emptyDir: {}
    - name: manifest-dir
      emptyDir: {}
```

## Kubectl Patch Deployment Image Example

If you have existing deployment and after period of time image of the application is being updated. So to update the container image in the deployment, this task can be used as this task will patch the image with the new image in the existing deployment. The TaskRun for this scenario can be found [here](./samples/update-deployment-image-taskrun.yaml)
