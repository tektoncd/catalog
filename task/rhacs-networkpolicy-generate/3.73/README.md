# Red Hat Advanced Cluster Security Generate NetworkPolicy Task

Generate suggested NetworkPolicy artifacts given source Kubernetes manifests using `roxctl`.

See the [RHACS documentation](https://docs.openshift.com/acs/3.73/operating/manage-network-policies.html) for more detail.

**This is a Technology Preview feature**
Technology Preview features are not supported with Red Hat production service level agreements (SLAs) and might not be functionally complete. Red Hat does not recommend using them in production. These features provide early access to upcoming product features, enabling customers to test functionality and provide feedback during the development process. For more information about the support scope of Red Hat Technology Preview features, see <https://access.redhat.com/support/offerings/techpreview/>

## Prerequisites

This task requires an active installation of [Red Hat Advanced Cluster Security (RHACS)](https://www.redhat.com/en/resources/advanced-cluster-security-for-kubernetes-datasheet).  It also requires configuration of secrets for the Central endpoint and an API token with at least CI privileges.

<https://www.redhat.com/en/technologies/cloud-computing/openshift/advanced-cluster-security-kubernetes>

## Install the Task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/rhacs-networkpolicy-generate/3.73/raw
```

## Parameters

- **`manifests`**: Directory holding deployment manifests. May be relative to workspace root or fully qualified. Examples: _"k8s"_
- **`insecure-skip-tls-verify`**: Skip verification the TLS certs of the Central endpoint and registry. Examples: _"true", **"false"**_.
- **`networkpolicy-dir`**: Directory to store generated policies in. Example: _$(workspaces.source.path)/networkpolicies_
- **`rox_api_token`**: Secret containing the StackRox API token with CI permissions. Default: _**rox-api-token**_
- **`rox_central_endpoint`**: Secret containing the address:port tuple for StackRox Central. Default: _**rox-central-endpoint**_
- **`rox_image`**: Container image providing `roxctl`. Examples: _**quay.io/stackrox-io/roxctl:3.73.1**, registry.redhat.io/advanced-cluster-security/rhacs-roxctl-rhel8:3.73_

## Workspaces

- **source**: A [Workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md) containing the application manifests.

## Usage

Create secrets for authentication to RHACS Central endpoint and supply filesystem path to deployment manifests for analysis.

Run this task after checking out application manifest source code.

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
    - name: generate-networkpolicy
    taskRef:
      name: rhacs-networkpolicy-generate
      kind: Task
    workspaces:
      - name: source
        workspace: shared-workspace
    params:
      - name: manifests
        value: $(workspaces.source.path)/k8s
      - name: networkpolicy-dir
        value: '$(workspaces.source.path)/networkpolicy'
    runAfter:
      - fetch-repository
```

**Samples:**

* [secrets.yaml](samples/secrets.yaml) example secret
* [pipeline.yaml](samples/pipeline.yaml) demonstrates use in a pipeline.
* [pipelinerun.yaml](samples/pipelinerun.yaml) demonstrates use in a pipelinerun.

# Known Issues

* Skipping TLS Verify is currently required. TLS trust bundle not working for quay.io etc.
* It is not strictly true that a endpoint and token are required to generate network policies. The generate command acts locally, and does not contact Central. I'm not yet aware if the product could change to require a connection later, so these values are currently required by this task for consistency with related tasks.
* Even with empty values, `--output-dir` and `--output-file` may not be supplied simultaneously. This task takes the opinion that `--output-dir` is best and eschews other options for now.
  > _ERROR:    Flags [-d|--output-dir, -f|--output-file] cannot be used together_
  * **Possible RFE for roxctl:**
    * Permit both `--output-dir` and `--output-file` flags  to exist simultaneously.
    * In case of _non-null_ values for both, `exit 1`
    * In case of _non-null_ values for one, write to that location
    * In case of _null_ values for both, write to `STDOUT`
