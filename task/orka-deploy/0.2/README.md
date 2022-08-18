# Run macOS Builds with Tekton and Orka by MacStadium

> **IMPORTANT:** This `Task` requires **Tekton Pipelines v0.16.0 or later** and an Orka environment running on **Orka 1.4.1 or later**.

This `Task`, along with `orka-init` and `orka-teardown`, allows you to utilize multiple macOS build agents in your [Orka environment](https://orkadocs.macstadium.com).

## `orka-deploy`

A `Task` that deploys a VM instance from a specified VM template. Usually, you would use the VM template created with `orka-init`.

## Platforms

The Task can be run on `linux/amd64` platform.

## Prerequisites

* You need a Kubernetes cluster with Tekton Pipelines v0.16.0 or later configured.
* You need an Orka environment with the following components:
  * Orka 1.4.1 or later.
  * [An Orka service endpoint](https://orkadocs.macstadium.com/docs/endpoint-faqs#whats-the-orka-service-endpoint) (IP or custom domain). Usually, `http://10.221.188.20`, `http://10.221.188.100` or `https://<custom-domain>`.
  * A dedicated Orka user with valid credentials (email & password). Create a new user or request one from your Orka administrator.
  * An SSH-enabled base image and the respective SSH credentials (email & password OR SSH key). Use an [existing base image](https://orkadocs.macstadium.com/docs/existing-images-upload-management) or [create your own](https://orkadocs.macstadium.com/docs/creating-an-ssh-enabled-image).
* You need an active VPN connection between your Kubernetes cluster and Orka. Use a [VPN client](https://orkadocs.macstadium.com/docs/vpn-connect) for temporary access or create a [site-to-site VPN tunnel](https://orkadocs.macstadium.com/docs/aws-orka-connections) for permanent access.

See also: [Using Orka, At a Glance](https://orkadocs.macstadium.com/docs/quick-start-introduction)

See also: [GCP-MacStadium Site-to-Site VPN](https://docs.macstadium.com/docs/google-cloud-setup)

> **NOTE:** Beginning with Orka 2.1.0, net new Orka clusters are configured with the Orka service endpoint as `http://10.221.188.20`. Existing clusters will continue to use the service endpoint as initially configured, typically `http://10.221.188.100`.

## Installation

Before you can use this `Task` in Tekton pipelines, you need to install it and the Orka configuration in your Kubernetes cluster. See the `orka-init` documentation [here](https://github.com/tektoncd/catalog/blob/main/task/orka-init/0.2/README.md#installation) for more information on setting up the Orka API configuration.

```sh
kubectl apply --namespace=<namespace> -f https://raw.githubusercontent.com/tektoncd/catalog/task/orka-deploy/0.2/orka-deploy.yaml
```

Omit `--namespace` if installing in the `default` namespace.

## Storing SSH credentials

The `orka-deploy` task looks for a Kubernetes secret that stores the SSH access credentials for your macOS base image. This secret is called `orka-ssh-creds` by default and is expected to have the keys `username` and `password`.

These defaults exist for convenience, and you can change them using the available [`Task` parameters](#Configuring-Secrets-and-Config-Maps).

You can use the following example configuration. Make sure to provide the correct credentials for your base image.

```yaml
# orka-ssh-creds.yaml
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

```sh
kubectl apply --namespace=<namespace> -f orka-ssh-creds.yaml
```

Omit `--namespace` if installing in the `default` namespace.

### Using an SSH key

If using an SSH key to connect to the VM instead of an SSH username and password, complete the following:

1. Copy the public key to the VM and commit the base image.
2. Store the username and private key in a Kubernetes secret:

```sh
kubectl create secret generic orka-ssh-key --from-file=id_rsa=/path/to/id_rsa --from-literal=username=<username>
```

See also: [use-ssh-key.yaml](https://github.com/tektoncd/catalog/blob/main/task/orka-deploy/0.2/samples/use-ssh-key.yaml) example

## Workspaces

* **orka**: The contents of this workspace will be copied to the deployed VM. All files present in the workspace will be available to the build script run inside the VM. For example, you could clone a git repository containing Objective-C or Swift code in a previous pipeline step and run a build with Xcode command line tools in your build script. If the `copy-build` parameter is set to true, all build artifacts will be copied from the VM back to the workspace.

## Parameters

### Common parameters

| Parameter | Description | Default |
| --- | --- | ---: |
| `vm-metadata` | Inject custom metadata to the VM (on Intel nodes only). You need to provide the metadata in format:`[{ key: firstKey, value: firstValue }, { key: secondKey, value: secondValue }]`. Refer to [`inject-vm-metadata`](samples/inject-vm-metadata.yaml) example. | --- |
| `system-serial` | Assign an owned macOS system serial number to the VM (on Intel nodes only). Refer to [`inject-system-serial`](samples/inject-system-serial.yaml) example. | --- |
| `gpu-passthrough` | Enables or disables GPU passthrough for the VM (on Intel nodes only). Refer to [`gpu-passthrough`](samples/gpu-passthrough.yaml) example. | false |
| `script` | The script to run inside of the VM. The script will be prepended with `#!/bin/sh` and `set -ex` if no shebang is present. You can set your shebang instead (e.g., to run a script with your preferred shell or a scripting language like Python or Ruby). | --- |
| `copy-build` | Specifies whether to copy build artifacts from the Orka VM back to the workspace. Disable when there is no need to copy build artifacts (e.g., when running tests or linting code). | true |
| `verbose` | Enables verbose logging for all connection activity to the VM. | false |
| `ssh-key` | Specifies whether the SSH credentials secret contains an [SSH key](#using-an-ssh-key), as opposed to a password. | false |
| `delete-vm` | Specifies whether to delete the VM after use when run in a pipeline. You can discard build agents that are no longer needed to free up resources. Set to false if you intend to clean up VMs after use manually. | true |
| `orka-tekton-runner-image` | The docker image used to run the task steps. | ghcr.io/macstadium/orka-tekton-runner:2022-06-29-ec3440a7@sha256:d7cfb75ea082a927e36c131aa96e96bfcacd23f62fdaf33f5b37320b86baf50e |

### Configuring secrets and config maps

| Parameter | Description | Default |
| --- | --- | ---: |
| `ssh-secret` | The name of the secret holding your VM SSH credentials. | orka-ssh-creds |
| `ssh-username-key` | The name of the key in the VM SSH credentials secret for the username associated with the macOS VM. | username |
| `ssh-password-key` | The name of the key in the VM SSH credentials secret for the password associated with the macOS VM. If `ssh-key` is true, this parameter should specify the name of the key in the VM SSH credentials secret that holds the private SSH key. | password |
| `orka-token-secret` | The name of the secret holding the authentication token used to access the Orka API. Applicable to `orka-init` / `orka-deploy` / `orka-teardown`. | orka-token |
| `orka-token-secret-key` | The name of the key in the Orka token secret, which holds the authentication token. Applicable to `orka-init` / `orka-deploy` / `orka-teardown`. | token |
| `orka-vm-name-config` | The name of the config map, which stores the name of the generated VM configuration. Applicable to `orka-init` / `orka-deploy` / `orka-teardown`. | orka-vm-name |
| `orka-vm-name-config-key` | The name of the key in the VM name config map, which stores the name of the generated VM configuration. Applicable to `orka-init` / `orka-deploy` / `orka-teardown`. | vm-name |

## Samples

[parallel-deploy.yaml](https://github.com/tektoncd/catalog/blob/main/task/orka-deploy/0.2/samples/parallel-deploy.yaml) is a sample `Pipeline` that uses the `orka-init`, `orka-deploy`, and `orka-teardown` tasks and performs the following operations:
1. Sets up an Orka job runner.
2. Deploys 2 VMs in parallel and executes a different script on each VM.
3. Cleans up the environment.
