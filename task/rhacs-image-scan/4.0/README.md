# Red Hat Advanced Cluster Security Image Scan Task

Scan an image for vulnerabilities and metadata against RHACS build and deploy
lifecycle policies to validate a pipeline run using `roxctl`.

This tasks allows you to return full vulnerability scan results for an image in
JSON, CSV, or Pretty format.  It's a companion to the rhacs-image-check task.

**Note: this Task is not backwards compatible with the `3.71` version as it
changes the parameters and token configuration.**

**Note: this Task requires a 4.4.2 roxctl image (task default) or a more recent 
image version.**

## Prerequisites

This task requires an active installation of [Red Hat Advanced Cluster Security (RHACS)](https://www.redhat.com/en/resources/advanced-cluster-security-for-kubernetes-datasheet)
or [StackRox](https://www.stackrox.io/).  It also requires configuration of an
authorization token with at least CI privileges.

<https://www.redhat.com/en/technologies/cloud-computing/openshift/advanced-cluster-security-kubernetes>

## Install the Task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/rhacs-image-scan/4.0/raw
```

## Parameters

- **`image`**: Full name of image to scan. Examples: _gcr.io/rox/sample:5.0-rc1,
**$(params.IMAGE)**, $(params.IMAGE)@$(tasks.buildah.results.IMAGE_DIGEST)_
- **`output_format`**:  Examples: _**json**, csv, pretty_

- **`rox_central_endpoint`**: The address:port tuple for StackRox Central.
Default: **central.stackrox.svc:443**
- **`insecure-skip-tls-verify`**: Skip verification the TLS certs of the Central
endpoint and registry. Examples: _"true", **"false"**_.
- **`rox_config_dir`**: Path to the roxctl config directory within the
`roxctl-config` workspace (if machine to machine authentication is used).
Mutually exclusive with **`rox_token_file`**. The path must be prefixed with
`/roxctl-config`. Examples: _"/roxctl-config", **""**_.
- **`rox_token_file`**: Path to the API Token file (if API Token authentication
is used). Mutually exclusive with **`rox_config_dir`**. The path must be
prefixed with `/rox-api-token-auth`.
Examples: _**""**, "/rox-api-token-auth/rox_api_token"_.
- `rox_image`: The image providing the roxctl tool (optional).
Default: quay.io/stackrox-io/roxctl:4.4.2
(this is also the minimum version working with this task). 
- `output_file`: path to a file where to redirect roxctl standard output.
Default: "" (redirects to stdout).
- `error_file`: path to a file where to redirect roxctl standard error.
Default: "" (redirects to stderr).

One of the **`rox_config_dir`** or **`rox_token_file`** parameter is required
for the authentication against the remote Central to work.

## Workspaces

- **roxctl-config**: An [optional workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md#optional-workspaces)
containing the configuration for roxctl. Used to authenticate with the remote
central using short-lived tokens. The content of this workspace has to be
populated by a rhacs-m2m-authenticate TaskRun. This workspace is mutually
exclusive with the `rox-api-token-auth` workspace.
- **rox-api-token-auth**: An [optional workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md#optional-workspaces)
containing a rox token file. Used to authenticate with the remote central. It is
**strongly** recommended that this workspace be bound to a Kubernetes `Secret`.
This workspace is mutually exclusive with the `roxctl-config` workspace.

## Usage

Scans images that have been pushed to a registry.  This enables scanning
regardless of whether the build is using traditional Docker-based approaches,
hosted/SaaS-based approaches where the Docker socket may not be directly
available, or rootless approaches like `kaniko` and `buildah`.

If the image violates one or more enforced policies, this task will return a
failure and cause the pipeline run to fail.

### Configure using machine to machine authentication

Check the [documentation](https://docs.openshift.com/acs/operating/manage-user-access/configure-short-lived-access.html#configure-short-lived-access_configure-short-lived-access)
to configure the trust with the OIDC token issuer. This
[example](../../rhacs-m2m-authenticate/0.1/samples/configure-m2m.md) describes
a possible RHACS machine-to-machine integration configuration.

The token exchange itself is taken care of by the
[rhacs-m2m-authenticate](../../rhacs-m2m-authenticate) task.

**Example task use:**

The task configuration in that case must provide the `roxctl-config` workspace
and the `rox_config_dir` parameter with values pointing at the location where
the roxctl configuration is made available.

```yaml
  tasks:
    - name: image-scan
      taskRef:
        name: rhacs-image-scan
        kind: Task
      workspaces:
      - name: roxctl-config
        workspace: shared-workspace
      params:
      - name: image
        value: "$(params.image)@$(tasks.build-image.results.IMAGE_DIGEST)"
      - name: rox_central_endpoint
        value: central.stackrox.svc:443
      - name: rox_config_dir
        value: /roxctl-config
      runAfter:
      - build-image
```

**Samples:**

* [pipeline.yaml](samples/with-m2m-token/pipeline.yaml) demonstrates use in a
pipeline.
* [pipelinerun.yaml](samples/with-m2m-token/pipelinerun.yaml) demonstrates use
in a pipelinerun.

### Configure using secret holding API token

**Example secret creation:**

Check the [documentation](https://docs.openshift.com/acs/configuration/configure-api-token.html)
for API token creation.

```bash
kubectl create secret generic rox-api-token \
  --from-literal=rox_api_token="$ROX_API_TOKEN"
```

**Example task use:**

The task configuration in that case must provide the `rox-api-token-auth`
workspace and the `rox_token_file` parameter with values pointing at the
location where the API token is made available.

```yaml
  tasks:
    - name: image-scan
      taskRef:
        name: rhacs-image-scan
        kind: Task
      workspaces:
        - name: rox-api-token-auth
          secret:
            secretName: rox-api-token
      params:
        - name: image
          value: "$(params.IMAGE)@$(tasks.build-image.results.IMAGE_DIGEST)"
        - name: rox_central_endpoint
          value: central.stackrox.svc:443
        - name: rox_token_file
          value: /rox-api-token-auth/rox_api_token
      runAfter:
      - build-image
```

**Samples:**

- [secrets.yaml](samples/with-api-token/secrets.yaml) example secret
- [pipeline.yaml](samples/with-api-token/pipeline.yaml) demonstrates use in a
pipeline.
- [pipelinerun.yaml](samples/with-api-token/pipelinerun.yaml) demonstrates use
in a pipelinerun.

# Known Issues

* Skipping TLS Verify is currently required. TLS trust bundle not working for
quay.io etc.
* Saving scan output as a 'result' does not work, because it is often larger
than 4KB. This also would require container invocation via script.

  ```
  STEP-ROX-IMAGE-SCAN

  {"level":"fatal","ts":1659318163.069173,"caller":"entrypoint/entrypointer.go:188","msg":"Error while handling results: Termination message is above max allowed size 4096, caused by large task result.","stacktrace":"github.com/tektoncd/pipeline/pkg/entrypoint.Entrypointer.Go\n\t/opt/app-root/src/go/src/github.com/tektoncd/pipeline/pkg/entrypoint/entrypointer.go:188\nmain.main\n\t/opt/app-root/src/go/src/github.com/tektoncd/pipeline/cmd/entrypoint/main.go:154\nruntime.main\n\t/usr/lib/golang/src/runtime/proc.go:225"}
  ```
