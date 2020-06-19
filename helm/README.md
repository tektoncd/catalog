# Helm

This Task installs / upgrades a helm chart into your Kubernetes / OpenShift Cluster using [Helm](https://github.com/helm/helm).

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/helm/helm-upgrade.yaml
```

## Parameters

- **CHARTS_DIR**: The directory in the source repository where the installable chart should be found.
- **RELEASE_VERSION**: The version of the release (*default: v1.0.0*)
- **RELEASE_NAME**: The name of the release (*default: helm-release*)
- **RELEASE_NAMESPACE**: The namespace in which the release is to be installed (*default: ""*)
- **OVERWRITE_VALUES**: The values to be overwritten (*default: ""*)
- **HELM_VERSION**: The helm version which should be used (*default: latest*)

## Workspaces

* **source**: A `git`-type `PipelineResource` specifying the location of the helm chart.


## Usage

### PipelineRun

An example `Pipeline` with a `PipelineRun` can be found in the subdirectory `tests`.

### TaskRun

This `TaskRun` runs the task to retrieve a Git repo and then installs/updates the helm chart that is in the Git repo.


```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: example-helm-upgrade
spec:
  taskRef:
    name: helm-upgrade
  params:
  - name: CHARTS_DIR
    value: helm-sample-chart
  - name: RELEASE_VERSION
    value: v1.0.0
  - name: RELEASE_NAME
    value: helm-sample
  - name: OVERWRITE_VALUES
    value: "autoscaling.enabled=true,autoscaling.maxReplicas=3"
  workspaces:
  - name: source
    persistentVolumeClaim:
      claimName: my-source
```
