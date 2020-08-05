# Tekton Pipelines Install

The Task `tekton-pipelines-install` can be used to install Tekton Pipelines (very meta!).

If you are looking to manage an installation of Tekton Pipelines, you probably want to use
https://github.com/tektoncd/operator instead. This Task can be used to apply a specified
release of Tekton to an existing cluster, for example for testing.

## Parameters

* **pipelines-version**: The version of Tekton Pipelines to install. Expected format `v.0.0`. (_required_)

## Workspaces

* **kubeconfig**: A workspace into which a kubeconfig file called `kubeconfig` has been written that contains
  the information required to access the cluster. The current context configured in this file should refer to
  a user that has permission to install the Tekton Pipelines components.

## Usage

See [samples/install.yaml](samples/install.yaml) for an example of a Pipeline that uses
[boskos-acquire](../../boskos-acquire) to obtain a project using Boskos, creates a new cluster using
[gke-cluster-create](../../gke-cluster-create), uses [gke-add-cluster-admin](../../gke-cluster-admin)
to create a cluster admin users and then with that user, installs Tekton Pipelines with this Task.
