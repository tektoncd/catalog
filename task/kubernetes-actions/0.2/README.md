# kubernetes actions

This is a generic task used to perform kubernetes actions such as `kubectl get deployment` or `kubectl create -f filename.yaml`. For more commands [see](https://kubernetes.io/docs/reference/kubectl/overview/).

## Install the task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/kubernetes-actions/0.2/kubernetes-actions.yaml
```

## Inputs

### Parameters

- **script**: script of `kubectl` commands to execute e.g. `kubectl get pod $1 -0 yaml`. This will take the first value of ARGS as pod name (_default_: `kubectl $@`)
- **args**: args to execute which are appended to `kubectl` e.g. `start-build myapp` (_default_: `help`)
- **image**: Default image being `gcr.io/cloud-builders/kubectl`. If somebody wants to use their own image then they can provide it as a part of params. For example an image avilable is `lachlanevenson/k8s-kubectl`

### Workspaces(Optional)

- **kubeconfig-dir**: If you want to deploy you application to another cluster then you can mount your `kubeconfig` file via this `workspace`.
- **manifest-dir**: Manifest files can be provided via the workspaces.

## Results

- **output-result**: If you want to emit some result which can be used in decision making. One such case is when using [whenExpressions](https://github.com/tektoncd/pipeline/blob/main/docs/pipelines.md#guard-task-execution-using-whenexpressions).

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

In case no manifests are mounted

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: kubectl-run
spec:
  taskRef:
    name: kubernetes-actions
  params:
    - name: script
      value: |
        kubectl get pods 
        echo "-----------"
        kubectl get deploy
```

In case manifest is present on `GitHub` :

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: kubectl-run
spec:
  taskRef:
    name: kubernetes-actions
  params:
    - name: script
      value: |
        kubectl apply -f https://raw.githubusercontent.com/vinamra28/social-client/master/k8s/deployment.yaml
        ----------
        kubectl get deployment
```

Running `kubectl` commands on other cluster

1. Create a `ConfigMap` or `Secret` which contains `kubeconfig`

   ```sh
   kubectl create configmap kubeconfig --from-file="/path/to/kubeconfig"
   ```

2. Create the `TaskRun`
   ```yaml
   apiVersion: tekton.dev/v1beta1
   kind: TaskRun
   metadata:
     name: kubectl-run
   spec:
     taskRef:
       name: kubernetes-actions
     workspaces:
       - name: kubeconfig-dir
         configMap:
           name: kubeconfig
     params:
       - name: script
         value: |
           kubectl apply -f https://raw.githubusercontent.com/vinamra28/social-client/master/k8s/deployment.yaml
           ----------
           kubectl get deployment
   ```

## Kubectl Patch Deployment Image Example

If you have existing deployment and after period of time image of the application is being updated. So to update the container image in the deployment, this task can be used as this task will patch the image with the new image in the existing deployment. The TaskRun for this scenario can be found [here](./samples/update-deployment-image-taskrun.yaml)
