# GKE Add Cluster Admin

The Task `gke-add-cluster-admin` can be used to create a user with cluster admin priviledges
in an existing GKE cluster.

This Task will authenticate with a GKE cluster using gcloud and then create a new
user in the cluster with cluster admin priviledges.

_The service account provided via gcp-service-account must have `container.clusterRoleBindings.create`
permissions in the target GKE project that the cluster lives in._

## ServiceAccount

This Task will use the service account provided via the `gcp-service-account` workspace and will
not use the permissions of the TaskRun's ServiceAccount.

## Parameters

* **private-key-path**: The path to the private key within the gcp-service-account workspace. (_required_)
* **new-username**: The name to give the new users. (_default_: cluster-admin)

## Workspaces

* **gcp-service-account**: A Secret or volume containing the private key of a GCP service account that can
  access the GKE cluster in the kubeconfig, is able to create users in the cluster and can grant
  cluster-admin permissions. gcloud auth will be initialized with this service account.
* **kubeconfig**: A workspace into which a kubeconfig file called `kubeconfig` has been written that contains
  the information required to access the cluster. The kubeconfig will be used in a container that has gcloud
  installed and so supports using gcloud to authenticate. The new user's token information will be added to
  tphe kubeconfig and the user for the current context will be set to this user.

## Usage

See [samples/install.yaml](samples/install.yaml) for an example of a Pipeline that uses
[boskos-acquire](../../boskos-acquire) to obtain a project using Boskos, creates a new cluster using
[gke-cluster-create](../../gke-cluster-create), uses this Task to create a cluster admin users and then
with that user, installs Tekton Pipelines with [tekton-pipelines-install](../../tekton-pipelines-install).
