# GKE Cluster Create

The Task `gke-cluster-create` can be used to create a GKE cluster in a GCP
project and fetch a kubeconfig that can be used (in a context with both kubectl and gcloud
available) to make requests to the cluster.

The cluster created will have a firewall applied such that the only traffic allowed to instances
in the cluster will be SSH, TCP services running on 80 or 8080, and services exposed via the
NodePort default range (https://kubernetes.io/docs/concepts/services-networking/service/#nodeport).

## Parameters

* **project-name**: The name of the GCP project in which to create the GKE cluster. (_required_)
* **private-key-path**: The path to the private key within the gcp-service-account workspace. (_required_)
* **identifier**: A string which identifies the purpose for which this cluster is being created. Used to name other resources created. (_required_)
* **min-nodes**: The minimum number of nodes in the cluster. (_default_:1)
* **max-nodes**: The maximum number of nodes in the cluster. (_default_:3)
* **region**: The region to create the cluster in. (_default_:us-central1)
* **machine-type**: The machine type to create, from
  https://cloud.google.com/compute/docs/machine-types. (_default_:n1-standard-4)
* **image-type**: The type of image to create the nodes, from
  https://cloud.google.com/kubernetes-engine/docs/concepts/node-images. (_default_:cos)
* **cluster-version**: The GKE version to install, in a format that can be used as the
    `--cluster-version` argument to https://cloud.google.com/sdk/gcloud/reference/beta/container/clusters/create
    (_default_: latest)

## Workspaces

* **gcp-service-account**: A Secret or volume containing the private key of a GCP service account
  that can create GKE clusters in the project
* **kubeconfig**: A workspace into which a kubeconfig file called `kubeconfig` will be written that
  will contain the information required to access the cluster. The `kubeconfig` will expect to use
  gcloud to authenticate, so in order for it to be used it must be run in a container which contains
  both kubectl and gcloud.

## Results

* **cluster-name** The name of the cluster that was created.

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

See [samples/create-gke-cluster.yaml](samples/create-gke-cluster.yaml) for an example of a TaskRun
that creates a GKE cluster and writes the kubeconfig to a PVC.
