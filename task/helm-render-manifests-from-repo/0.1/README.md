# Helm Render Manifests From Repo

This task is designed to be used as part of an implementation of the GitOps [Rendered Manifests Pattern](https://akuity.io/blog/the-rendered-manifests-pattern/). It is intended to be unopinionated and as such will simply template a Helm chart and output a file to a workspace volume with an optionally specified name and location.

The task expects at least a Helm repository URL and Chart name. By default, the output will be a file named `manifest.yaml` in the current working directory. This can be configured to suit the needs of the user.

The task runs with `--validate` enabled to ensure that the `template` command, like `install`, will populate builtins such as `Capabilities` from the target server. This may not always be desirable, so can be disabled through the `extra_args` parameter

## Workspaces
This task requires a workspace for the rendered manifest. The working directory is in the root of the workspace so any custom path will need to be set relative to the root of the workspace.

* **target**: A [Workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md) volume containing the helm chart.



## Parameters

- **helm_repo**: The URL of the Helm repository to pull from
- **chart_name**: The fully qualified name of the chart, e.g. `my-repo/my-chart`
- **release_version**: The version of the release (*default: latest*)
- **release_name**: The name of the release (*default: helm-release*)
- **release_namespace**: The namespace in which the release is to be installed (*default: ""*)
- **manifest_filename**: The name of the output YAML file (*default: `manifest.yaml`*)
- **manifest_path**: The path for the generated YAML file (*default: `.`*)
- **extra_args**: Any extra CLI arguments, space separated (*default: `--validate --skip-tests`*)
- **overwrite_values**: The values to be overwritten (*default: ""*)
- **helm_image**: The container image which contains the Helm binary (*default: `docker.io/lachlanevenson/k8s-helm:v3.10.2`*)

## Platforms

The Task can be run on `linux/amd64`, `linux/s390x`, `linux/arm64` and `linux/ppc64le` platforms.

## Usage

### PipelineRun

An example `Pipeline` with a `PipelineRun` can be found in the subdirectory `tests`.

### TaskRun

This `TaskRun` runs the task to set up a Helm repository and generate a template. Validation is disabled in this example.

```yaml
# example rendered manifests from repo
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: example-helm-render-manifests-from-repo
spec:
  taskRef:
    name: helm-render-manifests-from-repo
  params:
  - name: helm_repo
    value: https://prometheus-community.github.io/helm-charts
  - name: chart_name
    value: prometheus-community/prometheus
  - name: release_version
    value: 25.21.0
  - name: release_name
    value: helm-repo-sample
  - name: extra_args
    value: '--skip-tests'
  - name: overwrite_values
    value: alertmanager.enabled=false,kube-state-metrics.enabled=false,prometheus-node-exporter.enabled=false,prometheus-pushgateway.enabled=false
```