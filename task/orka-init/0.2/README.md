# Run macOS Builds with Tekton and Orka by MacStadium

> **IMPORTANT:** This `Task` requires **Tekton Pipelines v0.16.0 or later** and an Orka environment running on **Orka 1.4.1 or later**.

This `Task`, along with `orka-deploy` and `orka-teardown`, allows you to utilize multiple macOS build agents in your [Orka environment](https://orkadocs.macstadium.com).

## `orka-init`

A `Task` that creates a VM template with the specified configuration. All operations in this `Task` are performed against an Orka environment.

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
* For the `orka-init` and `orka-teardown` tasks, you need a Kubernetes service account, a cluster role, and a cluster role binding. See [Kubernetes service account setup](#kubernetes-service-account-setup).

See also: [Using Orka, At a Glance](https://orkadocs.macstadium.com/docs/quick-start-introduction)

See also: [GCP-MacStadium Site-to-Site VPN](https://docs.macstadium.com/docs/google-cloud-setup)

> **NOTE:** Beginning with Orka 2.1.0, net new Orka clusters are configured with the Orka service endpoint as `http://10.221.188.20`. Existing clusters will continue to use the service endpoint as initially configured, typically `http://10.221.188.100`.

## Installation

Before you can use this `Task` in Tekton pipelines, you need to install it and the Orka configuration in your Kubernetes cluster.

You can use the following sample `orka-configuration.yaml`. Make sure to provide the correct Orka API endpoint for your Orka environment.

```yaml
# orka-configuration.yaml
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: orka-tekton-config
data:
  ORKA_API: http://10.221.188.20
```

```sh
kubectl apply --namespace=<namespace> -f orka-configuration.yaml
kubectl apply --namespace=<namespace> -f https://raw.githubusercontent.com/tektoncd/catalog/task/orka-init/0.2/orka-init.yaml
```

Omit `--namespace` if installing in the `default` namespace.

## Kubernetes service account setup

To use the `orka-init` and `orka-teardown` tasks, you need to configure a Kubernetes service account, a cluster role, and a cluster role binding.

You can use the following sample:

```yaml
# orka-runner.yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: orka-svc
  namespace: default
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

```sh
kubectl apply -f orka-runner.yaml
```

Make sure to specify the namespace in which the `orka-init` and `orka-teardown` tasks are installed when declaring the `ServiceAccount` and `ClusterRoleBinding`.

## Storing your credentials

The `orka-init` task looks for a Kubernetes secret that stores your Orka user credentials. This secret is called `orka-creds` by default and is expected to have the keys `email` and `password`.

These defaults exist for convenience, and you can change them using the available [`Task` parameters](#Configuring-Secrets-and-Config-Maps).

You can use the following example configuration. Make sure to provide the correct credentials for your Orka environment.

```yaml
# orka-creds.yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: orka-creds
type: Opaque
stringData:
  email: tekton-svc@macstadium.com
  password: p@ssw0rd
```

```sh
kubectl apply --namespace=<namespace> -f orka-creds.yaml
```

Omit `--namespace` if installing in the `default` namespace.

> **NOTE:** These credentials are used by the `orka-init` task to generate an authentication token to access the Orka API. This authentication token is then used by the `orka-deploy` and `orka-teardown` tasks for all API calls.

## Parameters

### Common parameters

| Parameter | Description | Default |
| --- | --- | ---: |
| `base-image` | The Orka base image to use for the VM config. | --- |
| `orka-tekton-runner-image` | The docker image used to run the task steps. | ghcr.io/macstadium/orka-tekton-runner:2022-06-29-ec3440a7@sha256:d7cfb75ea082a927e36c131aa96e96bfcacd23f62fdaf33f5b37320b86baf50e |
| `cpu-count` | The number of CPU cores to dedicate for the VM. Must be 3, 4, 6, 8, 12, or 24. | 3 |
| `vcpu-count` | The number of vCPUs for the VM. Must equal the number of CPUs, when CPU is less than or equal to 3. Otherwise, must equal half of or exactly the number of CPUs specified. | 3 |
| `vnc-console` | Enables or disables VNC for the VM. | false |
| `tag` | When specified, the VM is preferred to be deployed to a node marked with this tag. | --- |
| `tag-required` | VM is required to be deployed to a node marked with tag specified above. | false |
| `scheduler` | When set to 'most-allocated', the deployed VM will be scheduled to nodes having most of their resources allocated. | default |

### Configuring secrets and config maps

| Parameter | Description | Default |
| --- | --- | ---: |
| `orka-creds-secret` | The name of the secret holding your Orka credentials. | orka-creds |
| `orka-creds-email-key` | The name of the key in the Orka user credentials secret for the email address associated with the Orka user. | email |
| `orka-creds-password-key` | The name of the key in the Orka credentials secret for the password associated with the Orka user. | password |
| `orka-token-secret` | The name of the secret holding the authentication token used to access the Orka API. Applicable to `orka-init` / `orka-deploy` / `orka-teardown`. | orka-token |
| `orka-token-secret-key` | The name of the key in the Orka token secret, which holds the authentication token. Applicable to `orka-init` / `orka-deploy` / `orka-teardown`. | token |
| `orka-vm-name-config` | The name of the config map, which stores the name of the generated VM configuration. Applicable to `orka-init` / `orka-deploy` / `orka-teardown`. | orka-vm-name |
| `orka-vm-name-config-key` | The name of the key in the VM name config map, which stores the name of the generated VM configuration. Applicable to `orka-init` / `orka-deploy` / `orka-teardown`. | vm-name |
