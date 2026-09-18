# EKS Cluster Create

The Task `eks-cluster-create` can be used to create an EKS cluster in an AWS account, using the `eksctl` command,
and fetch a kubeconfig that can be used (in a context with both kubectl and aws credentials available) to make 
requests to the cluster.

## Parameters

* **cluster-name**: The name of the EKS cluster which you want to spin. (_required_)
* **cluster-version**: The EKS version to install. (_default_:1.17)
* **region**: The region where the cluster is in. (_default_:us-west-2)
* **zones**: The zones where the cluster is in. (_default_:us-west-2a,us-west-2b,us-west-2c)
* **nodegroup-name**: The name of the nodegroup of the cluster. (_default_:linux-nodes)
* **node-type**: The type of the EC2 instaces for the nodegroup of the cluster. (_default_:m5.xlarge)
* **desired-nodes**: The desired number of nodes in the cluster. (_default_:4)
* **min-nodes**: The minimum number of nodes in the cluster. (_default_:1)
* **max-nodes**: The maximum number of nodes in the cluster. (_default_:4)

## Workspaces

* **secrets**: A Secret containing the AWS credentials to run the create.
* **kubeconfig**: A workspace into which a kubeconfig file called `kubeconfig` will be written that will contain the information required to access the cluster. The `kubeconfig` will expect to use [aws-iam-authenticator](https://github.com/kubernetes-sigs/aws-iam-authenticator/) to authenticate, so in order for it to be used it must be run in a container which contains both `kubectl` and `aws-iam-authenticator`.

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

See [samples/create-eks-cluster.yaml](https://github.com/tektoncd/catalog/tree/main/task/eks-cluster-create/0.1/samples/create-eks-cluster.yaml) for an example of a TaskRun that creates a EKS cluster and writes the kubeconfig to a PVC.
