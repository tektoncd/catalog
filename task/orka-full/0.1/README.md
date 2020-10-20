# Run macOS Builds with Tekton and Orka by MacStadium

> **IMPORTANT:** This `Task` requires **Tekton Pipelines v0.16.0 or later** and an Orka environment running on **Orka 1.4.1 or later**.

This `Task` is for utilizing a single macOS build agent in your [Orka environment](https://orkadocs.macstadium.com).

This `Task` can replace the `orka-init`, `orka-deploy`, and `orka-teardown` modular tasks when your workflow works with a single macOS build agent.

## `orka-full`

A `Task` that creates a VM template with the specified configuration, deploys a VM instance from it, and then cleans up the environment. All operations in this `Task` are performed against an Orka environment.

## Prerequisites

* You need a Kubernetes cluster with Tekton Pipelines v0.16.0 or later configured.
* You need an Orka environment with the following components:
  * Orka 1.4.1 or later.
  * [An Orka service endpoint](https://orkadocs.macstadium.com/docs/endpoint-faqs#whats-the-orka-service-endpoint) (IP or custom domain). Usually, `http://10.221.188.100`, `http://10.10.10.100` or `https://<custom-domain>`.
  * A dedicated Orka user with valid credentials (email & password). Create a new user or request one from your Orka administrator.
  * An SSH-enabled base image and the respective SSH credentials (email & password OR SSH key). Use an [existing base image](https://orkadocs.macstadium.com/docs/existing-images-upload-management) or [create your own](https://orkadocs.macstadium.com/docs/creating-an-ssh-enabled-image). 
* You need an active VPN connection between your Kubernetes cluster and Orka. Use a [VPN client](https://orkadocs.macstadium.com/docs/vpn-connect) for temporary access or create a [site-to-site VPN tunnel](https://orkadocs.macstadium.com/docs/aws-orka-connections) for permanent access.

See also: [Using Orka, At a Glance](https://orkadocs.macstadium.com/docs/quick-start-introduction)

See also: [GCP-MacStadium Site-to-Site VPN](https://docs.macstadium.com/docs/google-cloud-setup)

## Installation

Before you can use this `Task` in Tekton pipelines, you need to install it and the Orka configuration in your Kubernetes cluster.

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

## Storing your credentials

The provided `Task` looks for two Kubernetes secrets that store your credentials: `orka-creds` for the Orka user and `orka-ssh-creds` for the SSH credentials.
  * `orka-creds` has the following keys: `email` and `password`
  * `orka-ssh-creds` has the following keys: `username` and `password`

These defaults exist for convenience, and you can change them using the available [`Task` parameters](#Configuring-Secrets).

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

### Configuring secrets

| Parameter | Description | Default |
| --- | --- | ---: |
| `orka-creds-secret` | The name of the secret holding your Orka credentials. | orka-creds |
| `orka-creds-email-key` | The name of the key in the Orka user credentials secret for the email address associated with the Orka user. | email |
| `orka-creds-password-key` | The name of the key in the Orka credentials secret for the password associated with the Orka user. | password |
| `ssh-secret` | The name of the secret holding your VM SSH credentials. | orka-ssh-creds |
| `ssh-username-key` | The name of the key in the VM SSH credentials secret for the username associated with the macOS VM. | username |
| `ssh-password-key` | The name of the key in the VM SSH credentials secret for the password associated with the macOS VM. If `ssh-key` is true, this parameter should specify the name of the key in the VM SSH credentials secret that holds the private SSH key. | password |

## Samples

[dump-disk-info.yaml](samples/dump-disk-info.yaml) is a sample `TaskRun` that uses the `orka-full` `Task` to create a VM, run a script on it, and then clean up the environment.

[build-audiokit-pipeline.yaml](samples/build-audiokit-pipeline.yaml) is a  sample `Pipeline` that uses the `orka-full` `Task` and performs the following operations:
1. Clones a git repository.
2. Passes it to the Orka build agent.
3. Stores build artifacts on a persistent volume.
4. Cleans up the Orka environment.