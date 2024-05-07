# Red Hat Advanced Cluster Security Deployment Check Task

Check a deployment manifest against RHACS deploy lifecycle policies to validate
a pipeline run using `roxctl`.

**Note: this Task is not backwards compatible with the `3.71` versions as it
changes the parameters and token configuration.**

**Note: this Task requires a 4.4.2 roxctl image (task default) or a more
recent image version.**

## Prerequisites

This task requires an active installation of
[Red Hat Advanced Cluster Security (RHACS)](https://www.redhat.com/en/resources/advanced-cluster-security-for-kubernetes-datasheet)
or [StackRox](https://www.stackrox.io).  It also requires configuration of
an authorization token with at least CI privileges.

<https://www.redhat.com/en/technologies/cloud-computing/openshift/advanced-cluster-security-kubernetes>

## Install the Task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/rhacs-deployment-check/4.0/raw
```

## Parameters

- **`deployment`**: Filename of deployment manifest. May be relative to source
workspace root or fully qualified.
(example -- kustomize/overlays/dev/deployment.yaml)
- **`output_format`**:  Examples: _**table**, csv, json, junit_

- **`rox_central_endpoint`**: The address:port tuple for StackRox Central.
Default: **central.stackrox.svc:443**
- **`insecure-skip-tls-verify`**: Skip verification the TLS certs of the
Central endpoint and registry. Examples: _"true", **"false"**_.
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

- **source**: A [Workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md)
containing the deployment manifest.
- **roxctl-config**: An [optional workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md#optional-workspaces)
containing the configuration for roxctl. Used to authenticate with the remote
central using short-lived tokens. The content of this workspace has to be
populated by a rhacs-m2m-authenticate TaskRun. This workspace is mutually
exclusive with the `rox-api-token-auth` one.
- **rox-api-token-auth**: An [optional workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md#optional-workspaces)
containing a rox token file. Used to authenticate with the remote central. It
is **strongly** recommended that this workspace be bound to a Kubernetes
`Secret`. This one is mutually exclusive with the `roxctl-config` workspace.

## Usage

Configure machine to machine authentication or create secrets for
authentication to RHACS Central endpoint and supply filesystem path to
deployment manifest for checking.

**Note:** This task requires at least Read permission on the Detection
resource configured on RHACS Central side.

Run this task after rhacs-image-scan to ensure most up to date CVE data for
images referenced by the deployment.

If the deployment violates one or more enforced policies, this task will return
a failure and cause the pipeline run to fail. 

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
    - name: check-deployment
      taskRef:
        name: rhacs-deployment-check
        kind: Task
      workspaces:
      - name: source
        workspace: shared-workspace
      - name: roxctl-config
        workspace: shared-workspace
      params:
      - name: deployment
        value: $(params.deployment)
      - name: rox_central_endpoint
        value: central.stackrox.svc:443
      - name: rox_config_dir
        value: /roxctl-config
      runAfter:
      - fetch-repository
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
    - name: check-deployment
      taskRef:
        name: rhacs-deployment-check
        kind: Task
      workspaces:
      - name: source
        workspace: shared-workspace
      - name: rox-api-token-auth
        secret:
          secretName: rox-api-token
      params:
      - name: deployment
        value: $(params.deployment)
      - name: rox_central_endpoint
        value: central.stackrox.svc:443
      - name: rox_token_file
        value: /rox-api-token-auth/rox_api_token
      runAfter:
      - fetch-repository
```

**Samples:**

* [secrets.yaml](samples/with-api-token/secrets.yaml) example secret
* [pipeline.yaml](samples/with-api-token/pipeline.yaml) demonstrates use in a
pipeline.
* [pipelinerun.yaml](samples/with-api-token/pipelinerun.yaml) demonstrates use
in a pipelinerun.

# Known Issues

* Skipping TLS Verify is currently required. TLS trust bundle not working for
quay.io etc.
* If the namespace value is not found in the deployment manifest any
RHACS policies which are scoped to specific namespaces will not be matched.
