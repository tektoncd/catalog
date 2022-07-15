# Install Tekton & Components

This task can be used to install Tekton pipelines and also it's components using [Tekton Operator](https://github.com/tektoncd/operator) on a new cluster.

## Install the Task

```shell
kubectl apply --filename https://api.hub.tekton.dev/v1/resource/tekton/task/tekton-operator-install/0.1/raw
```

## Parameters

- **OPERATOR_VERSION**: Tekton Operator release version to be used for installing tekton components. (_Default_ : "latest")
- **INSTALL_TRIGGERS**: If [Triggers](https://github.com/tektoncd/triggers) needs to be installed. (_Default_ : "false")
- **INSTALL_DASHBOARD**: If [Tekton Dashboard](https://github.com/tektoncd/dashboard) needs to be installed. (_Default_ : "false")
- **INSTALL_EXTENSION_WEBHOOKS**: If [Tekton Extension Webhooks](https://github.com/tektoncd/experimental/tree/main/webhooks-extension) needs to be installed. (_Default_ : "false")

### Note: The last three parameters accepts value "true"/"false". Default being "false" means we don't want to install that component.

## Workspaces

- **kubeconfig**: The workspace consisting of the `kubeconfig` file of the new cluster on which tekton pipelines & components needs to be installed.

## Sample Usage

1. Create the `ConfigMap`

```shell
kubectl create configmap kubeconfig --from-file="path/to/kubeconfig"
```

2. Create a TaskRun in case you want to install Triggers

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: operator-run
spec:
  taskRef:
    name: tekton-operator-install
  params:
    - name: INSTALL_TRIGGERS
      value: "true"
  workspaces:
    - name: kubeconfig
      configMap:
        name: kubeconfig
```

3. Create a TaskRun in case you want to install Triggers as well as Dashboard

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: operator-run
spec:
  taskRef:
    name: tekton-operator-install
  params:
    - name: INSTALL_TRIGGERS
      value: "true"
    - name: INSTALL_DASHBOARD
      value: "true"
  workspaces:
    - name: kubeconfig
      configMap:
        name: kubeconfig
```
