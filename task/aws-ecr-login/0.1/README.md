# AWS ECR Login

This task retrieves an `authentication token` using the GetAuthorizationToken API 
that you can use to authenticate to an `Amazon ECR registry`. You can pass the 
authorization token to the login command of the container client of your preference,
such as the Docker CLI. After you have authenticated to an Amazon ECR registry with 
this authentication token, you can use the client to push and pull images from that 
registry as long as your IAM principal has access to do so until the token expires. 

*NOTE*: The authorization token is valid for 12 hours.

## Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/aws-ecr-login/0.1/raw
```

## Parameters

- **region**: Region for AWS, ensure that you specify the same 
    Region that your Amazon ECR registry exists in.

## Workspaces

- **secrets**: A workspace that consists of credentials required by the `aws` 
    which needs to be mounted to their default path as required by the aws.

## Secret

AWS `credentials` and `config` both should be provided in the form of `secret`.

Secret [example](../0.1/samples/secret.yaml)
can be referred to create `aws-credentials`.

Refer [aws docs](https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/setup-credentials.html) 
guide for setting up AWS Credentials and Region.

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

AWS ECR login task will be used to authenticate to Amazon ECR registry. 
This Task will give the `authentication token` in form of `result` 
of the task and this token can be used for authentication.

Once you get the `authentication token` you can login using 
the login command of the container client of your preference. 

In the given [example](../0.1/samples) image is being pushed 
to Amazon ECR Registry and `buildah` is used 
as container client for the same.
