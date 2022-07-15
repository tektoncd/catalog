# Helm

These tasks will install / upgrade a helm chart into your Kubernetes / OpenShift Cluster using [Helm](https://github.com/helm/helm).

## Install the Task

### helm install / upgrade from source code

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/helm-upgrade-from-source/0.2/raw
```

#### Parameters

- **charts_dir**: The directory in the source repository where the installable chart should be found.
- **release_version**: The version of the release (*default: v1.0.0*)
- **release_name**: The name of the release (*default: helm-release*)
- **release_namespace**: The namespace in which the release is to be installed (*default: ""*)
- **overwrite_values**: The values to be overwritten (*default: ""*)
- **values_file**: The values file to be used,
    assumes the values file is in the same dir as your charts_dir (*default: "values.yaml"*)
- **helm_image**: The helm image which should be used (*default: lachlanevenson/k8s-helm:v3.3.4*)

#### Workspaces

* **source**: A [Workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md) containing the helm chart.

#### Platforms

The Task can be run on `linux/amd64`, `linux/s390x`, `linux/arm64` and `linux/ppc64le` platforms.

## Usage

### PipelineRun

An example `Pipeline` with a `PipelineRun` can be found in the subdirectory `tests`.

### TaskRun

This `TaskRun` runs the task to retrieve a Git repo and then installs/updates the helm chart that is in the Git repo.

```yaml
# example upgrade from source
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: example-helm-upgrade-from-source
spec:
  taskRef:
    name: helm-upgrade-from-source
  params:
  - name: charts_dir
    value: helm-sample-chart
  - name: releases_version
    value: v1.0.0
  - name: release_name
    value: helm-source-sample
  - name: overwrite_values
    value: "autoscaling.enabled=true,autoscaling.maxReplicas=3"
  workspaces:
  - name: source
    persistentVolumeClaim:
      claimName: my-source
```