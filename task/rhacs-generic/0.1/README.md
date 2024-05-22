# Red Hat Advanced Cluster Security generic Task

Allows users to customize and extend
[`roxctl`](https://docs.openshift.com/acs/cli/command-reference/roxctl.html)
command line based on their needs.

This task first exchanges a service account token against a short-lived RHACS
authorization token, then performs the requested action.

**Note: this Task requires a 4.4.2 roxctl image (task default) or a more recent
image version.**

## Prerequisites

This task requires an active installation of [Red Hat Advanced Cluster Security (RHACS)](https://www.redhat.com/en/resources/advanced-cluster-security-for-kubernetes-datasheet)
or [StackRox](https://www.stackrox.io).  It also requires configuration of a
machine-to-machine integration.

<https://www.redhat.com/en/technologies/cloud-computing/openshift/advanced-cluster-security-kubernetes>

## Install the Task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/rhacs-generic/0.1/raw
```

## Parameters

- **`rox_central_endpoint`**: The address:port tuple for StackRox Central.
Default: **central.stackrox.svc:443**
- **`insecure-skip-tls-verify`**: Skip verification the TLS certs of the Central
endpoint and registry. Examples: _"true", **"false"**_.
- **`rox_arguments`**: The command line that you would like to enter, in array
form. (required)
- `rox_ca_cert_file`: Path to the Central CA PEM file (if certificates are
available). The path must be empty if no file is available, or prefixed with
`/workspace/ca` otherwise.
Examples: _**""**, "/workspace/ca/central-ca.pem"_
- `rox_image`: The image providing the roxctl tool (optional).
Default: quay.io/stackrox-io/roxctl:4.4.2
(this is also the minimum version working with this task). 
- `output_file`: path to a file where to redirect roxctl standard output.
Default: "" (redirects to stdout).
- `error_file`: path to a file where to redirect roxctl standard error.
Default: "" (redirects to stderr).

## Workspaces

- **data**: An [optional Workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md#optional-workspaces)
which stores files used as parameters to the command line.
- **ca**: An [optional Workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md#optional-workspaces)
which stores the Red Hat Advanced Cluster Security Central CA PEM file.
It is **strongly** recommended that this workspace be bound to a Kubernetes
`Secret`.

## Usage

Check the [documentation](https://docs.openshift.com/acs/operating/manage-user-access/configure-short-lived-access.html#configure-short-lived-access_configure-short-lived-access)
to configure the trust with the OIDC token issuer. This
[example](../../rhacs-m2m-authenticate/0.1/samples/configure-m2m.md) describes
a possible RHACS machine-to-machine integration configuration.

The `roxctl` [documentation](https://docs.openshift.com/acs/cli/command-reference/roxctl.html)
describes the available commands and their options.

**Example task uses:**

Declarative configuration preparation:
```yaml
    - name: create-access-scope
      taskRef:
        name: rhacs-generic
        kind: Task
      params:
        - name: insecure-skip-tls-verify
          value: "true"
        - name: rox_endpoint
          value: $(params.rox_central_endpoint)
        - name: rox_image
          value: $(params.rox_image)
        - name: rox_arguments
          value:
            - declarative-config
            - create
            - access-scope
            - --name=testScope
            - --description=test access scope
            - --included=testCluster=stackrox
```

Deployment check:
```yaml
  tasks:
    - name: check-deployment
      taskRef:
        name: rhacs-generic
        kind: Task
      params:
        - name: insecure-skip-tls-verify
          value: "true"
        - name: rox_endpoint
          value: central.stackrox.svc:443
        - name: rox_arguments
          value:
            - deployment
            - check
            - --output=table
            - --file=/workspace/data/$(params.deployment)
      workspaces:
        - name: data
          workspace: shared-workspace
```

Image scan:
```yaml
  tasks:
    - name: scan-image
      taskRef:
        name: rhacs-generic
        kind: Task
      params:
        - name: insecure-skip-tls-verify
          value: "true"
        - name: rox_endpoint
          value: central.stackrox.svc:443
        - name: rox_arguments
          value:
            - image
            - scan
            - --output=table
            - --image=$(params.IMAGE)@$(tasks.build-image.results.IMAGE_DIGEST)
      runAfter:
        - build-image

```

**Samples:**

* [pipeline.yaml](samples/pipeline.yaml) demonstrates use in a pipeline.
* [pipelinerun.yaml](samples/pipelinerun.yaml) demonstrates use
in a pipelinerun.

# Known Issues

