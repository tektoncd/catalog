# EKS Cluster Teardown

The Task `eks-cluster-teardown` can be used to teardown an EKS cluster in an AWS account, using the `eksctl` command.

## Parameters

* **cluster-name**: The name of the EKS cluster which will be teared down. (_required_)
* **region**: The region where the cluster is in. (_default_:us-west-2)

## Workspaces

* **secrets**: A Secret containing the AWS credentials to run the teardown.

## Secret

AWS `credentials` and `config` both should be provided in the form of `secret`.

[This](https://github.com/tektoncd/catalog/tree/main/task/eks-cluster-teardown/0.1/samples/secret.yaml) example can be referred to create `aws-credentials`.

Refer [this](https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/setup-credentials.html) guide for setting up AWS Credentials and Region.

The AWS user/role should have the [minimum IAM policies](https://eksctl.io/usage/minimum-iam-policies/) defined by `eksctl`.

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

See [samples/teardown-eks-cluster.yaml](https://github.com/tektoncd/catalog/tree/main/task/eks-cluster-teardown/0.1/samples/teardown-eks-cluster.yaml) for an example of a TaskRun that tears down an EKS cluster.
