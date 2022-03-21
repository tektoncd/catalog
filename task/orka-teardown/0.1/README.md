# Run macOS Builds with Tekton and Orka by MacStadium

> **IMPORTANT:** This `Task` requires **Tekton Pipelines v0.16.0 or later** and an Orka environment running on **Orka 1.4.1 or later**.

This `Task`, along with `orka-init` and `orka-deploy`, allows you to utilize multiple macOS build agents in your [Orka environment](https://orkadocs.macstadium.com).

## `orka-teardown`

A `Task` that cleans up the Orka environment after your workload completes. This `Task` deletes the VM instances deployed with `orka-deploy` and their related template.

## Platforms

The Task can be run on `linux/amd64` platform.

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

Before you can use this `Task` in Tekton pipelines, you need to install it and the Orka configuration in your Kubernetes cluster. See the `orka-init` documentation [here](https://github.com/tektoncd/catalog/blob/main/task/orka-init/0.1/README.md#installation) for more information on setting up the Orka API configuration.

```sh
kubectl apply --namespace=<namespace> -f https://raw.githubusercontent.com/tektoncd/catalog/task/orka-teardown/0.1/orka-teardown.yaml
```

Omit `--namespace` if installing in the `default` namespace.

## Kubernetes service account setup

To use the `orka-init` and `orka-teardown` tasks, you need to configure a Kubernetes service account, a cluster role, and a cluster role binding.

See the `orka-init` documentation [here](https://github.com/tektoncd/catalog/blob/main/task/orka-init/0.1/README.md#kubernetes-service-account-setup) for more information on setting up a service account.

## Parameters

| Parameter | Description | Default |
| --- | --- | ---: |
| `orka-token-secret` | The name of the secret holding the authentication token used to access the Orka API. Applicable to `orka-init` / `orka-deploy` / `orka-teardown`. | orka-token |
| `orka-token-secret-key` | The name of the key in the Orka token secret, which holds the authentication token. Applicable to `orka-init` / `orka-deploy` / `orka-teardown`. | token |
| `orka-vm-name-config` | The name of the config map, which stores the name of the generated VM configuration. Applicable to `orka-init` / `orka-deploy` / `orka-teardown`. | orka-vm-name |
| `orka-vm-name-config-key` | The name of the key in the VM name config map, which stores the name of the generated VM configuration. Applicable to `orka-init` / `orka-deploy` / `orka-teardown`. | vm-name |
| `orka-image` | The docker image used to run the task steps. | docker.io/macstadium/orka-tekton-runner:2020-10-23-a93757dc-0.1@sha256:e8ed3370dcb91cdb8bcd4e9a7e9f6652879d80acdab9644cda69a98cd8c93339 |
