# Red Hat Advanced Cluster Security Image Check Task

Check an image against RHACS build and deploy lifecycle policies to validate a pipeline run using `roxctl`.

It's a companion to the rhacs-image-scan task, which returns full vulnerability scan results for an image.

## Prerequisites

This task requires an active installation of [Red Hat Advanced Cluster Security (RHACS)](https://www.redhat.com/en/resources/advanced-cluster-security-for-kubernetes-datasheet).  It also requires configuration of secrets for the Central endpoint and an API token with at least CI privileges.

## Install the Task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/rhacs-image-check/3.71/raw
```

## Parameters

- **`image`**: Full name of image to scan. Examples: _gcr.io/rox/sample:5.0-rc1, **$(params.IMAGE)**, $(params.IMAGE)@$(tasks.buildah.results.IMAGE_DIGEST)_
- **`insecure-skip-tls-verify`**: Skip verification the TLS certs for Central endpoint and registry. Examples: _"true", **"false"**_.
- **`output_format`**:  Examples: _**table**, csv, json, junit_
- **`rox_central_endpoint`**: Secret containing the address:port tuple for StackRox Central. Default: _**rox-central-endpoint**_
- **`rox_api_token`**: Secret containing the StackRox API token with CI permissions. Default: _**rox-api-token**_

## Usage

Checks images that have been pushed to a registry.  This enables scanning regardless of whether the build is using traditional Docker-based approaches, hosted/SaaS-based approaches where the Docker socket may not be directly available, or rootless approaches like `kaniko` and `buildah`.

If the image violates one or more enforced policies, this task will return a failure and cause the pipeline run to fail.

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
    - name: image-check
      taskRef:
        name: rhacs-image-check
        kind: Task
      params:
        - name: image
          value: "$(params.IMAGE)@$(tasks.build-image.results.IMAGE_DIGEST)"
      runAfter:
      - image-scan
```

**Samples:**

- [secrets.yaml](samples/secrets.yaml) example secret
- [pipeline.yaml](samples/pipeline.yaml) demonstrates use in a pipeline.
- [pipelinerun.yaml](samples/pipelinerun.yaml) demonstrates use in a pipelinerun.

# Known Issues

* Skipping TLS Verify is currently required. TLS trust bundle not working for quay.io etc.