# Red Hat Advanced Cluster Security Deployment Check Task

Check a deployment manifest against RHACS deploy lifecycle policies to validate a pipeline run using `roxctl`.

## Prerequisites

This task requires an active installation of [Red Hat Advanced Cluster Security (RHACS)](https://www.redhat.com/en/resources/advanced-cluster-security-for-kubernetes-datasheet).  It also requires configuration of secrets for the Central endpoint and an API token with at least CI privileges.

<https://www.redhat.com/en/technologies/cloud-computing/openshift/advanced-cluster-security-kubernetes>

## Install the Task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/rhacs-deployment-check/3.71/raw
```

## Parameters

- **`deployment`**: Filename of deployment manifest. May be relative to workspace root or fully qualified. (example -- kustomize/overlays/dev/deployment.yaml)
- **`insecure-skip-tls-verify`**: Skip verification the TLS certs of the Central endpoint and registry. Examples: _"true", **"false"**_.
- **`output_format`**:  Examples: _**table**, csv, json, junit_
- **`rox_central_endpoint`**: Secret containing the address:port tuple for StackRox Central. Default: _**rox-central-endpoint**_
- **`rox_api_token`**: Secret containing the StackRox API token with CI permissions. Default: _**rox-api-token**_
## Workspaces

- **source**: A [Workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md) containing the deployment manifest.

## Usage

Create secrets for authentication to RHACS Central endpoint and supply filesystem path to deployment manifest for checking.

Run this task after rhacs-image-scan to ensure most up to date CVE data for images referenced by the deployment.

If the deployment violates one or more enforced policies, this task will return a failure and cause the pipeline run to fail. 

**Example secret creation:**

```bash
kubectl create secret generic rox-api-token \
  --from-literal=rox_api_token="$ROX_API_TOKEN"
kubectl create secret generic rox-central-endpoint \
  --from-literal=rox_central_endpoint=central.stackrox.svc:443
```

**Example task use:**

```yaml
  tasks:
    - name: check-deployment
    taskRef:
      name: rhacs-deployment-check
      kind: Task
    workspaces:
    - name: source
      workspace: shared-workspace
    params:
    - name: deployment
      value: $(params.deployment)
    runAfter:
    - fetch-repository
```

**Samples:**

* [secrets.yaml](samples/secrets.yaml) example secret
* [pipeline.yaml](samples/pipeline.yaml) demonstrates use in a pipeline.
* [pipelinerun.yaml](samples/pipelinerun.yaml) demonstrates use in a pipelinerun.

# Known Issues

* Skipping TLS Verify is currently required. TLS trust bundle not working for quay.io etc.
* If the namespace value is not found in the deployment manifest any RHACS policies which are scoped to specific namespaces will not be matched.