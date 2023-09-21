# Valint

Valint is a tool used to manage `evidence` generation (for directories, file artifacts, images, and git repositories), storage and validation. Valint currently supports two types of evidence: **CycloneDX SBOMs** and **SLSA provenance**. It enables cryptographically signing the evidence generated allowing you to later verify artifacts against their origin and signer identity. 

Valint also enables you to **capture** any 3rd party report, scan or configuration (any file) into evidence. 

## Usage
```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: valint-test-pipeline
spec:
  workspaces:
  - name: shared-workspace
  tasks:
  - name: valint-bom
    taskRef:
      name: valint
    params:
    - name: args
      value: bom busybox:latest
```

## Parameters

| Parameter | Description | Default |
| --- | --- | ---: |
| `scribe-secret` | The name of the secret that has the scribe security secrets. | scribe-secret |
| `args` | Arguments of the `valint` CLI | |
| `image-version-sha` | The ID of the valint image cli to be used. | |

### Evidence Stores
Each storer can be used to store, find and download evidence, unifying all the supply chain evidence into a system is an important part to be able to query any subset for policy validation.

| Type  | Description | requirement |
| --- | --- | --- |
| scribe | Evidence is stored on scribe service | scribe credentials |
| OCI | Evidence is stored on a remote OCI registry | access to a OCI registry |

## Scribe Evidence store
Scribe evidence store allows you store evidence using scribe Service.

Related Flags:
> Note the flag set:
>* `-U`, `--scribe.client-id`
>* `-P`, `--scribe.client-secret`
>* `-E`, `--scribe.enable`

### Before you begin
Integrating Scribe Hub with your environment requires the following credentials that are found in the **Integrations** page. (In your **[Scribe Hub](https://prod.hub.scribesecurity.com/ "Scribe Hub Link")** go to **integrations**)

* **Client ID**
* **Client Secret**

* Store credentials in [kubernetes secret](https://kubernetes.io/docs/concepts/configuration/secret/)


#### Storing your credentials

The `valint` task looks for a Kubernetes secret that stores your Scribe user credentials. This secret is called `scribe-secret` by default and is expected to have the keys `scribe-client-id` and `scribe-client-secret`.
You can use the following example configuration. Make sure to provide the correct credentials for your Scribe environment.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: orka-creds
type: Opaque
stringData:
  scribe_client_id: $(client_id)
  scribe_client_secret: $(client_secret)
  scribe_enable: true
```

```sh
kubectl apply --namespace=<namespace> -f scribe-secret.yaml
```

Omit `--namespace` if installing in the `default` namespace.

> **NOTE:** These credentials are used by the `valint` task to generate an authentication token to access the Scribe API.


### Usage

```yaml
# Creates a CycloneDX SBOM and verifies its policy.
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: basic-tests
spec:
  workspaces:
  - name: shared-workspace
  tasks:
  - name: valint-bom
    taskRef:
      name: valint
    workspaces:
    - name: output
      workspace: shared-workspace
    params:
    - name: args
      value: 
        - bom 
        - busybox:latest
        - -o=statement

  - name: valint-verify-bom
    taskRef:
      name: valint
    workspaces:
    - name: output
      workspace: shared-workspace
    runAfter:
    - valint-verify
    params:
    - name: args
      value: 
        - verify 
        - busybox:latest 
        - -i=statement
```

```yaml
# Creates a SLSA Provanence and verifies its policy.
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: basic-tests
spec:
  workspaces:
  - name: shared-workspace
  tasks:
  - name: valint-slsa
    taskRef:
      name: valint
    workspaces:
    - name: output
      workspace: shared-workspace
    runAfter:
    - valint-verify-bom
    params:
    - name: args
      value: 
        - slsa 
        - alpine:latest
        - -o=statement

  - name: valint-verify-slsa
    taskRef:
      name: valint
    workspaces:
    - name: output
      workspace: shared-workspace
    runAfter:
    - valint-slsa
    params:
    - name: args
      value: 
        - verify 
        - alpine:latest 
        - -i=statement-slsa
```

### Alternative evidence stores
> You can learn more about alternative stores **[here](https://scribe-security.netlify.app/docs/integrating-scribe/other-evidence-stores)**.

<details>
  <summary> <b> OCI Evidence store </b></summary>
Valint supports both storage and verification flows for `attestations`  and `statement` objects utilizing OCI registry as an evidence store.

Using OCI registry as an evidence store allows you to upload, download and verify evidence across your supply chain in a seamless manner.

Related flags:
* `--oci` Enable OCI store.
* `--oci-repo` - Evidence store location.


### Before you begin
Evidence can be stored in any accusable registry.
* Write access is required for upload (generate).
* Read access is required for download (verify).

You must first login with the required access privileges to your registry before calling Valint.

### Usage
```yaml
# Creates a CycloneDX SBOM and verifies its policy.
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: basic-tests
spec:
  workspaces:
  - name: shared-workspace
  tasks:
  - name: valint-bom
    taskRef:
      name: valint
    workspaces:
    - name: output
      workspace: shared-workspace
    params:
    - name: args
      value: 
        - bom 
        - busybox:latest
        - -o=statement
        - --oci
        - --oci-repo [my_repo]

  - name: valint-verify-bom
    taskRef:
      name: valint
    workspaces:
    - name: output
      workspace: shared-workspace
    runAfter:
    - valint-bom
    params:
    - name: args
      value: 
        - verify 
        - busybox:latest 
        - -i=statement
        - --oci
        - --oci-repo [my_repo]
```

```yaml
# Creates a SLSA Provanence and verifies its policy.
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: basic-tests
spec:
  workspaces:
  - name: shared-workspace
  tasks:
  - name: valint-slsa
    taskRef:
      name: valint
    workspaces:
    - name: output
      workspace: shared-workspace
    runAfter:
    - valint-verify-bom
    params:
    - name: args
      value: 
        - slsa 
        - busybox:latest
        - -o=statement
        - --oci
        - --oci-repo [my_repo]

  - name: valint-verify-slsa
    taskRef:
      name: valint
    workspaces:
    - name: output
      workspace: shared-workspace
    runAfter:
    - valint-slsa
    params:
    - name: args
      value: 
        - verify 
        - busybox:latest 
        - -i=statement-slsa
        - --oci
        - --oci-repo [my_repo]
```

</details>

## Basic examples
<details>
  <summary>  Public registry image (SBOM) </summary>

Create SBOM for remote `busybox:latest` image.

```YAML
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: basic-tests
spec:
  workspaces:
  - name: shared-workspace
  tasks:
  - name: valint-bom
    taskRef:
      name: valint
    workspaces:
    - name: output
      workspace: shared-workspace
    params:
    - name: args
      value: 
        - bom 
        - alpine:latest
``` 

</details>
<details>
  <summary>  Public registry image (SLSA) </summary>

Create SLSA for remote `busybox:latest` image.

```YAML
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: basic-tests
spec:
  workspaces:
  - name: shared-workspace
  tasks:
  - name: valint-slsa
    taskRef:
      name: valint
    workspaces:
    - name: output
      workspace: shared-workspace
    params:
    - name: args
      value: 
        - slsa
        - alpine:latest
``` 

</details>

<details>
  <summary> Custom metadata (SBOM) </summary>

Custom metadata added to SBOM.

```YAML
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: basic-tests
spec:
  workspaces:
  - name: shared-workspace
  tasks:
  - name: valint-bom
    taskRef:
      name: valint
    workspaces:
    - name: output
      workspace: shared-workspace
    params:
    - name: args
      value: 
        - bom 
        - busybox:latest
        - --env=test_env
        - --label=test_label
```
</details>


<details>
  <summary> Custom metadata (SLSA) </summary>

Custom metadata added to SLSA.

```YAML
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: basic-tests
spec:
  workspaces:
  - name: shared-workspace
  tasks:
  - name: valint-slsa
    taskRef:
      name: valint
    workspaces:
    - name: output
      workspace: shared-workspace
    params:
    - name: args
      value: 
        - slsa 
        - busybox:latest
        - --env=test_env
        - --label=test_label
```
</details>


<details>
  <summary> Archive image (SBOM) </summary>

Create SBOM for local `docker save` output.

> Use `oci-archive` target type when creating a OCI archive (`podman save`).

```YAML
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: basic-tests
spec:
  workspaces:
  - name: shared-workspace
  tasks:
  - name: valint-bom
    taskRef:
      name: valint
    workspaces:
    - name: output
      workspace: shared-workspace
    params:
    - name: args
      value: 
        - bom 
        - docker-archive:busybox.tar
```
</details>

<details>
  <summary> Archive image (SLSA) </summary>

Create SLSA for local `docker save` output.

> Use `oci-archive` target type when creating a OCI archive (`podman save`).

```YAML
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: basic-tests
spec:
  workspaces:
  - name: shared-workspace
  tasks:
  - name: valint-slsa
    taskRef:
      name: valint
    workspaces:
    - name: output
      workspace: shared-workspace
    params:
    - name: args
      value: 
        - slsa
        - docker-archive:busybox.tar
```
</details>

<details>
  <summary> Directory target (SBOM) </summary>

Create SBOM for a local directory.

```YAML
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: basic-tests
spec:
  workspaces:
  - name: shared-workspace
  tasks:
  - name: valint-bom
    taskRef:
      name: valint
    workspaces:
    - name: output
      workspace: shared-workspace
    params:
    - name: args
      value: 
        - bom 
        - dir:testdir
```
</details>

<details>
  <summary> Directory target (SLSA) </summary>

Create SLSA for a local directory.

```YAML
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: basic-tests
spec:
  workspaces:
  - name: shared-workspace
  tasks:
  - name: valint-bom
    taskRef:
      name: valint
    workspaces:
    - name: output
      workspace: shared-workspace
    params:
    - name: args
      value: 
        - slsa 
        - dir:testdir
```
</details>


<details>
  <summary> Git target (SBOM) </summary>

Create SBOM for `mongo-express` remote git repository.

```YAML
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: basic-tests
spec:
  workspaces:
  - name: shared-workspace
  tasks:
  - name: valint-bom
    taskRef:
      name: valint
    workspaces:
    - name: output
      workspace: shared-workspace
    params:
    - name: args
      value: 
        - bom 
        - git:https://github.com/mongo-express/mongo-express.git
```

Create SBOM for local git repository. <br />

> When using implicit checkout note the Gitlab-CI [git-strategy](https://docs.gitlab.com/ee/ci/runners/configure_runners.html#git-strategy) will effect the commits collected by the SBOM.

```YAML
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: basic-tests
spec:
  workspaces:
  - name: shared-workspace
  tasks:
  - name: valint-bom
    taskRef:
      name: valint
    workspaces:
    - name: output
      workspace: shared-workspace
    params:
    - name: args
      value: 
        - bom 
        - git:.
``` 
</details>

<details>
  <summary> Git target (SLSA) </summary>

Create SLSA for `mongo-express` remote git repository.

```YAML
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: basic-tests
spec:
  workspaces:
  - name: shared-workspace
  tasks:
  - name: valint-slsa
    taskRef:
      name: valint
    workspaces:
    - name: output
      workspace: shared-workspace
    params:
    - name: args
      value: 
        - slsa 
        - git:https://github.com/mongo-express/mongo-express.git
```

Create SLSA for local git repository. <br />

> When using implicit checkout note the Gitlab-CI [git-strategy](https://docs.gitlab.com/ee/ci/runners/configure_runners.html#git-strategy) will effect the commits collected by the SBOM.

```YAML
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: basic-tests
spec:
  workspaces:
  - name: shared-workspace
  tasks:
  - name: valint-slsa
    taskRef:
      name: valint
    workspaces:
    - name: output
      workspace: shared-workspace
    params:
    - name: args
      value: 
        - slsa 
        - git:.
``` 
</details>