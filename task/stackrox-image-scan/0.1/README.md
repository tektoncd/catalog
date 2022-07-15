# StackRox/Red Hat Advanced Cluster Security Image Scan Task

This tasks allows you to return full vulnerability scan results for an image in JSON, CSV, or Pretty format.  It's a companion to the stackrox-image-check task, which checks an image against build-time policies.

## Prerequisites

This task requires an active installation of [Red Hat Advanced Cluster Security (RHACS)](https://www.redhat.com/en/resources/advanced-cluster-security-for-kubernetes-datasheet) or [StackRox](https://www.stackrox.io/).  It also requires configuration of secrets for the Central endpoint and an API token with at least CI privileges.  `samples\rox-secrets.yaml` shows how to create the appropriate secrets.

## Install the Task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/stackrox-image-scan/0.1/raw
```

## Parameters

- **rox_central_endpoint**: Secret containing the address:port tuple for StackRox Central (example - rox.stackrox.io:443)
- **rox_api_token**: Secret containing the StackRox API token with CI permissions
- **image**: Full name of image to scan (example -- gcr.io/rox/sample:5.0-rc1)
- **output_format**:  Output format (json | csv | pretty).  This parameter is optional -- if omitted, the default format it JSON.
- **insecure-skip-tls-verify**: When set to `"true"`, skip verifying the TLS certs of the Central endpoint.  Defaults to `"false"`.

## Usage

StackRox/RHACS scans images that have been pushed to a registry.  This enables scanning regardless of whether the build is using traditional Docker-based approaches, hosted/SaaS-based approaches where the Docker socket may not be directly available, or rootless approaches like `kaniko` and `buildah`.

`samples\rox-pipeline.yaml` is a sample pipeline that takes the image to scan as a parameter.  Calling the task directly looks like this:

```yaml
  tasks:
    - name: image-scan
        taskRef:
        name: rox-image-scan
        kind: ClusterTask
        params:
            - name: image
            value: docker.io/stackrox/kube-linter:0.2.2
            - name: rox_api_token
            value: roxsecrets
            - name: rox_central_endpoint
            value: roxsecrets
            - name: output_format
            value: pretty
```
