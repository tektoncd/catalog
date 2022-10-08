# Red Hat Advanced Cluster Security Image Scan Task

Scan an image for vulnerabilities and metadata against RHACS build and deploy lifecycle policies to validate a pipeline run using `roxctl`.

This tasks allows you to return full vulnerability scan results for an image in JSON, CSV, or Pretty format.  It's a companion to the rhacs-image-check task.

## Prerequisites

This task requires an active installation of [Red Hat Advanced Cluster Security (RHACS)](https://www.redhat.com/en/resources/advanced-cluster-security-for-kubernetes-datasheet) or [StackRox](https://www.stackrox.io/).  It also requires configuration of secrets for the Central endpoint and an API token with at least CI privileges.

## Install the Task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/rhacs-image-scan/3.71/raw
```

## Parameters

- **`image`**: Full name of image to scan. Examples: _gcr.io/rox/sample:5.0-rc1, **$(params.IMAGE)**, $(params.IMAGE)@$(tasks.buildah.results.IMAGE_DIGEST)_
- **`insecure-skip-tls-verify`**: Skip verification the TLS certs for Central endpoint and registry. Examples: _"true", **"false"**_.
- **`output_format`**:  Examples: _**json**, csv, pretty_
- **`rox_central_endpoint`**: Secret containing the address:port tuple for StackRox Central. Default: _**rox-central-endpoint**_
- **`rox_api_token`**: Secret containing the StackRox API token with CI permissions. Default: _**rox-api-token**_

## Usage

Scans images that have been pushed to a registry.  This enables scanning regardless of whether the build is using traditional Docker-based approaches, hosted/SaaS-based approaches where the Docker socket may not be directly available, or rootless approaches like `kaniko` and `buildah`.

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
    - name: image-scan
      taskRef:
        name: rhacs-image-scan
        kind: Task
        params:
          - name: image
            value: "$(params.IMAGE)@$(tasks.build-image.results.IMAGE_DIGEST)"
      runAfter:
      - build-image
```

**Samples:**

- [secrets.yaml](samples/secrets.yaml) example secret
- [pipeline.yaml](samples/pipeline.yaml) demonstrates use in a pipeline.
- [pipelinerun.yaml](samples/pipelinerun.yaml) demonstrates use in a pipelinerun.

# Known Issues

* Skipping TLS Verify is currently required. TLS trust bundle not working for quay.io etc.
* Saving scan output as a 'result' does not work, because it is often larger than 4KB. This also would require container invocation via script.

  ```
  STEP-ROX-IMAGE-SCAN

  {"level":"fatal","ts":1659318163.069173,"caller":"entrypoint/entrypointer.go:188","msg":"Error while handling results: Termination message is above max allowed size 4096, caused by large task result.","stacktrace":"github.com/tektoncd/pipeline/pkg/entrypoint.Entrypointer.Go\n\t/opt/app-root/src/go/src/github.com/tektoncd/pipeline/pkg/entrypoint/entrypointer.go:188\nmain.main\n\t/opt/app-root/src/go/src/github.com/tektoncd/pipeline/cmd/entrypoint/main.go:154\nruntime.main\n\t/usr/lib/golang/src/runtime/proc.go:225"}
  ```

* Version of roxctl should maintain compatibility with Central API. Maximum allowable version drift is unknown.