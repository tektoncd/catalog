# Helm Chart Testing

These tasks make it possible to use [chart-testing](https://github.com/helm/chart-testing) within your Tekton pipelines. Chart Testing is a tool for lint and install testing helm charts, either as individual charts, or part of a monorepo.


## Installation

```console
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/task/helm-chart-testing/0.1/helm-chart-testing.yaml
```

## Usage


Once installed, the task can be used as follows:

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: helm-chart-testing-example
spec:
  taskRef:
    name: helm-chart-testing
  workspaces:
  - name: source
    persistentVolumeClaim:
      claimName: my-source
  params: # TODO FIX ME...
  - name: chart
    value: stable/mysql
  - name: policy
    value: stable/mysql/policy
```

## Parameters

- `image`: The chart-testing Docker image to use (default: `quay.io/helmpack/chart-testing:v3.0.0`)
- `config`: The path to the config file
- `command`: The chart-testing command to run
- `kubeconfig`: The path to the kube config file

## Workspaces
# FIXME
* **source**: A [Workspace](https://github.com/tektoncd/pipeline/blob/master/docs/workspaces.md) containing the source to build.
