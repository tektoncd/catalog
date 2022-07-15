# Helm

These tasks will install / upgrade a helm chart into your Kubernetes / OpenShift Cluster using [Helm](https://github.com/helm/helm).

## Install the Task

#### Workspaces

* **source**: A [Workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md) volume containing the helm chart.

### helm install / upgrade from repo

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/helm-upgrade-from-repo/0.1/raw
```

#### Parameters

- **chart_name**: The directory in the source repository where the installable chart should be found.
- **release_version**: The version of the release (*default: v1.0.0*)
- **release_name**: The name of the release (*default: helm-release*)
- **release_namespace**: The namespace in which the release is to be installed (*default: ""*)
- **overwrite_values**: The values to be overwritten (*default: ""*)
- **helm_version**: The helm version which should be used (*default: latest*)

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

### PipelineRun

An example `Pipeline` with a `PipelineRun` can be found in the subdirectory `tests`.

### TaskRun

This `TaskRun` runs the task to retrieve a Git repo and then installs/updates the helm chart that is in the Git repo.

```yaml
# example upgrade from repo
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: example-helm-upgrade-from-repo
spec:
  taskRef:
    name: helm-upgrade-from-repo
  params:
  - name: helm_repo
    value: https://kubernetes-charts.storage.googleapis.com
  - name: chart_name
    value: stable/envoy
  - name: release_version
    value: v1.0.0
  - name: release_name
    value: helm-repo-sample
  - name: overwrite_values
    value: autoscaling.enabled=true,autoscaling.maxReplicas=3
```