# Run macOS Builds with Tekton and Orka by MacStadium

> **IMPORTANT:** These `Tasks` require **Tekton Pipelines v0.16.0 or later** and an Orka environment running on **Orka 1.4.1 or later**.

These `Tasks` utilize multiple macOS build agents, in parallel or series, in your [Orka environment](https://orkadocs.macstadium.com).

## `orka-modular`

`orka-modular.yaml` combines the following three modular `Tasks`: `orka-init`, `orka-deploy`, and `orka-teardown`.

With these `Tasks`, you can build an end-to-end `Pipeline` that works with multiple macOS build agents.

### `orka-init`

A `Task` that creates a VM template with the specified configuration. All operations in this `Task` are performed against an Orka environment.

### `orka-deploy`

A `Task` that deploys a VM instance from a specified VM template. Usually, you would use the VM template created with `orka-init`. 

### `orka-teardown`

A `Task` that cleans up the Orka environment after your workload completes. This `Task` deletes the VM instances deployed with `orka-deploy` and their related templates.

## Prerequisites

* You need a Kubernetes cluster with Tekton Pipelines v0.16.0 or later configured.
* You need an Orka environment with the following components:
  * Orka 1.4.1 or later.
  * [An Orka service endpoint](https://orkadocs.macstadium.com/docs/endpoint-faqs#whats-the-orka-service-endpoint) (IP or custom domain). Usually, `http://10.221.188.100`, `http://10.10.10.100` or `https://<custom-domain>`.
  * A dedicated Orka user with valid credentials (email & password). Create a new user or request one from your Orka administrator.
  * An SSH-enabled base image and the respective SSH credentials (email & password OR SSH key). Use an [existing base image](https://orkadocs.macstadium.com/docs/existing-images-upload-management) or [create your own](https://orkadocs.macstadium.com/docs/creating-an-ssh-enabled-image). 
* You need an active VPN connection between your Kubernetes cluster and Orka. Use a [VPN client](https://orkadocs.macstadium.com/docs/vpn-connect) for temporary access or create a [site-to-site VPN tunnel](https://orkadocs.macstadium.com/docs/aws-orka-connections) for permanent access.
* For the `orka-init` and `orka-teardown` tasks, you need a Kubernetes service account, a cluster role, and a cluster role binding. See [Kubernetes service account setup](#kubernetes-service-account-setup).

See also: [Using Orka, At a Glance](https://orkadocs.macstadium.com/docs/quick-start-introduction)

See also: [GCP-MacStadium Site-to-Site VPN](https://docs.macstadium.com/docs/google-cloud-setup)

## Installation

Before using these `Tasks` in Tekton pipelines, you need to install them and the Orka configuration in your Kubernetes cluster.

**Default namespace installation**

To install in your Kubernetes cluster's `default` namespace, run the following command against your actual Orka API endpoint.

```sh
ORKA_API=http://10.221.188.100 ./install.sh --apply
```

To uninstall from the `default` namespace, run the script with the `-d` or `--delete` flag:

```sh
./install.sh --delete
```

**Custom namespace installation**

To install in a custom namespace, run the following command against your preferred namespace and your actual Orka API endpoint:

```sh
NAMESPACE=tekton-orka ORKA_API=http://10.221.188.100 ./install.sh --apply
```

To uninstall from a selected namespace, run the script with the `-d` or `--delete` flag against the namespace:

```sh
NAMESPACE=tekton-orka ./install.sh --delete
```

## Kubernetes service account setup

To use the `orka-init` and `orka-teardown` tasks, you need to configure a Kubernetes service account, a cluster role, and a cluster role binding. 

**Script setup**

To create the service account in your `default` namespace, run the following command:

```sh
./add-service-account.sh --apply
```

To remove the service account from the `default` namespace, run:

```sh
./add-service-account.sh --delete
```

To create the service account in a custom namespace, run the following command against the namespace:

```sh
NAMESPACE=tekton-orka ./add-service-account.sh --apply
```

To remove the service account from the custom namespace, run the following command against the namespace:

```sh
NAMESPACE=tekton-orka ./add-service-account.sh --delete
```

**Manual setup**

If you want to set up the service account manually, you can use this sample configuration:

```yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: orka-svc
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: orka-runner
rules:
  - apiGroups: [""]
    resources:
      - configmaps
      - secrets
    verbs:
      - create
      - delete
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: orka-runner
subjects:
- kind: ServiceAccount
  name: orka-svc
  namespace: default
roleRef:
  kind: ClusterRole
  name: orka-runner
  apiGroup: rbac.authorization.k8s.io
```

## Storing your credentials

The provided `Tasks` look for two Kubernetes secrets that store your credentials: `orka-creds` for the Orka user and `orka-ssh-creds` for the SSH credentials.
  * `orka-creds` has the following keys: `email` and `password`
  * `orka-ssh-creds` has the following keys: `username` and `password`

These defaults exist for convenience, and you can change them using the available [`Task` parameters](#Configuring-Secrets-and-Config-Maps).

**Script setup**

You need to create Kubernetes secrets to store the Orka user credentials and the base image's SSH credentials.

To create a Kubernetes secret in the `default` namespace of your cluster, run the following commands:

```sh
EMAIL=<email> PASSWORD=<password> ./add-orka-creds.sh --apply
SSH_USERNAME=<username> SSH_PASSWORD=<password> ./add-ssh-creds.sh --apply
```

To remove the secrets from the `default` namespace, run:

```sh
./add-orka-creds.sh --delete
./add-ssh-creds.sh --delete
```

To create a Kubernetes secret in a custom namespace, run the following commands against your preferred namespace:

```sh
NAMESPACE=tekton-orka EMAIL=<email> PASSWORD=<password> ./add-orka-creds.sh --apply
NAMESPACE=tekton-orka SSH_USERNAME=<username> SSH_PASSWORD=<password> ./add-ssh-creds.sh --apply
```

To remove the secrets from the custom specify, run the following commands against the namespace:

```sh
NAMESPACE=tekton-orka ./add-orka-creds.sh --delete
NAMESPACE=tekton-orka ./add-ssh-creds.sh --delete
```

**Manual setup**

If you want to create the Kubernetes secrets manually, you can use the following example configuration. Make sure to provide the correct credentials for your Orka environment and the base image.


```yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: orka-creds
type: Opaque
stringData:
  email: tekton-svc@macstadium.com
  password: p@ssw0rd
---
apiVersion: v1
kind: Secret
metadata:
  name: orka-ssh-creds
type: Opaque
stringData:
  username: admin
  password: admin
```

#### Using an SSH key

If using an SSH key to connect to the VM instead of an SSH username and password, complete the following:

1. Copy the public key to the VM and commit the base image.
2. Store the username and private key in a Kubernetes secret:

```sh
kubectl create secret generic orka-ssh-key --from-file=id_rsa=/path/to/id_rsa --from-literal=username=<username>
```

See also: [`use-ssh-key`](samples/use-ssh-key.yaml) example

## Workspaces

* **orka**: An Orka environment against which to perform all operations. The environment parameters are configured with the `Task` parameters.

## Parameters

### Common parameters

| Parameter | Description | Default |
| --- | --- | ---: |
| `base-image` | The Orka base image to use for the VM config. | --- |
| `cpu-count` | The number of CPU cores to dedicate for the VM. Must be 3, 4, 6, 8, 12, or 24. | 3 |
| `vcpu-count` | The number of vCPUs for the VM. Must equal the number of CPUs, when CPU is less than or equal to 3. Otherwise, must equal half of or exactly the number of CPUs specified. | 3 |
| `vnc-console` | Enables or disables VNC for the VM. | false |
| `script` | The script to run inside of the VM. The script will be prepended with `#!/bin/sh` and `set -ex` if no shebang is present. You can set your shebang instead (e.g., to run a script with your preferred shell or a scripting language like Python or Ruby). | --- |
| `copy-build` | Specifies whether to copy build artifacts from the Orka VM back to the workspace. Disable when there is no need to copy build artifacts (e.g., when running tests or linting code). | true |
| `verbose` | Enables verbose logging for all connection activity to the VM. | false |
| `ssh-key` | Specifies whether the SSH credentials secret contains an [SSH key](#using-an-ssh-key), as opposed to a password. | false |
| `delete-vm` | Applicable *only* to the `orka-deploy` task. Specifies whether to delete the VM after use when run in a pipeline. You can discard build agents that are no longer needed to free up resources. Set to false if you intend to clean up VMs after use manually. | true |

### Configuring secrets and config maps

| Parameter | Description | Default |
| --- | --- | ---: |
| `orka-creds-secret` | The name of the secret holding your Orka credentials. | orka-creds |
| `orka-creds-email-key` | The name of the key in the Orka user credentials secret for the email address associated with the Orka user. | email |
| `orka-creds-password-key` | The name of the key in the Orka credentials secret for the password associated with the Orka user. | password |
| `ssh-secret` | The name of the secret holding your VM SSH credentials. | orka-ssh-creds |
| `ssh-username-key` | The name of the key in the VM SSH credentials secret for the username associated with the macOS VM. | username |
| `ssh-password-key` | The name of the key in the VM SSH credentials secret for the password associated with the macOS VM. If `ssh-key` is true, this parameter should specify the name of the key in the VM SSH credentials secret that holds the private SSH key. | password |
| `orka-token-secret` | The name of the secret holding the authentication token used to access the Orka API. Applicable to `orka-init` / `orka-deploy` / `orka-teardown`. | orka-token |
| `orka-token-secret-key` | The name of the key in the Orka token secret, which holds the authentication token. Applicable to `orka-init` / `orka-deploy` / `orka-teardown`. | token |
| `orka-vm-name-config` | The name of the config map, which stores the name of the generated VM configuration. Applicable to `orka-init` / `orka-deploy` / `orka-teardown`. | orka-vm-name |
| `orka-vm-name-config-key` | The name of the key in the VM name config map, which stores the name of the generated VM configuration. Applicable to `orka-init` / `orka-deploy` / `orka-teardown`. | vm-name |

### Samples

[parallel-deploy.yaml](samples/parallel-deploy.yaml) is a sample `Pipeline` that uses the `orka-init`, `orka-deploy`, and `orka-teardown` `Tasks` and performs the following operations:
1. Sets up an Orka job runner.
2. Deploys 2 VMs and executes a different script on each VM.
3. Cleans up the environment.