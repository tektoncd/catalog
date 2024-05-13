# Red Hat Advanced Cluster Security Machine to machine authentication Task

Exchanges a service account token against a short-lived RHACS authorization
token to configure a pipeline run using `roxctl`.

**Note: this Task requires a 4.4.2 roxctl image (task default) or a more recent
image version.**

## Prerequisites

This task requires an active installation of [Red Hat Advanced Cluster Security (RHACS)](https://www.redhat.com/en/resources/advanced-cluster-security-for-kubernetes-datasheet)
or [StackRox](https://www.stackrox.io).  It also requires configuration of a
machine-to-machine integration.

<https://www.redhat.com/en/technologies/cloud-computing/openshift/advanced-cluster-security-kubernetes>

## Install the Task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/rhacs-m2m-authenticate/0.1/raw
```

## Parameters

- **`rox_central_endpoint`**: The address:port tuple for StackRox Central.
Default: **central.stackrox.svc:443**
- **`insecure-skip-tls-verify`**: Skip verification the TLS certs of the Central
endpoint and registry. Examples: _"true", **"false"**_.
- **`rox_config_dir`**: Path to the roxctl config directory within the
`roxctl-config` workspace (if machine to machine authentication is used). The
path must be prefixed with `/roxctl-config`.
Examples: _"/roxctl-config", **""**_.
- `rox_image`: The image providing the roxctl tool (optional).
Default: quay.io/stackrox-io/roxctl:4.4.2
(this is also the minimum version working with this task). 
- `output_file`: path to a file where to redirect roxctl standard output.
Default: "" (redirects to stdout).
- `error_file`: path to a file where to redirect roxctl standard error.
Default: "" (redirects to stderr).

## Workspaces

- **roxctl-config**: A [Workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md)
in which to write the configuration for roxctl.

## Usage


Check the [documentation](https://docs.openshift.com/acs/operating/manage-user-access/configure-short-lived-access.html#configure-short-lived-access_configure-short-lived-access)
to configure the trust with the OIDC token issuer. This
[example](samples/configure-m2m.md) describes a possible RHACS
machine-to-machine integration configuration.

This task performs the token exchange itself.

**Example task use:**

The task configuration in that case must provide the `roxctl-config` workspace
and the `rox_config_dir` parameter with values pointing at the location where
the roxctl configuration will be written.

```yaml
  tasks:
    - name: authenticate-to-rhacs
      taskRef:
        name: rhacs-m2m-authenticate
        kind: Task
      workspaces:
      - name: roxctl-config
        workspace: shared-workspace
      params:
      - name: rox_central_endpoint
        value: central.stackrox.svc:443
      - name: rox_config_dir
        value: /roxctl-config
      runAfter:
      - fetch-repository
```

**Samples:**

* [pipeline.yaml](samples/pipeline.yaml) demonstrates use in a pipeline.
* [pipelinerun.yaml](samples/pipelinerun.yaml) demonstrates use in a pipelinerun.

# Known Issues

* Skipping TLS Verify is currently required.
