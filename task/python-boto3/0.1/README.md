# Python Boto3 Task

This Tekton Task defines a reusable Task named `python-boto3` for running Python scripts that use the boto3 library to interact with AWS services.

## Parameters

The Task accepts the following parameters:

- `aws-region` (optional, default: `us-east-1`): The AWS region to use for the boto3 client.

## Volumes

The Task expects a ConfigMap named `python-script-configmap` to be mounted as a volume named `python-script`. This ConfigMap should contain the Python script to be executed, with the key `script.py`.

## Steps

The Task consists of a single step that runs the Python script using the `python:3.9` image. The step performs the following actions:

1. Installs the `boto3` library using `pip`.
2. Sets the AWS credentials as environment variables (`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`) from a Kubernetes Secret named `aws-credentials`.
3. Sets the AWS region as an environment variable (`AWS_DEFAULT_REGION`) using the value provided in the `aws-region` parameter.
4. Mounts the `python-script` volume containing the Python script at `/workspace/python-script`.
5. Executes the Python script located at `/workspace/python-script/script.py`.

## Usage

To use this Task, you'll need to create the following resources:

1. A Kubernetes Secret named `aws-credentials` with your AWS Access Key ID and Secret Access Key.
2. A ConfigMap named `python-script-configmap` with your Python script (`script.py`).

 Python script named script.py with the following content:

#####################################################
# script.py - begin
#####################################################
import boto3

# Your Python script that uses boto3 goes here
# For example:
s3 = boto3.client('s3')
response = s3.list_buckets()

print(response)

###################################################
# script.py - end
###################################################
To create the ConfigMap, you can use the kubectl create configmap command and specify the --from-file flag to include the Python script file:
######
# command to create configmap
#####
kubectl create configmap python-script-configmap --from-file=script.py
This command will create a ConfigMap named python-script-configmap with the contents of the script.py file.
Alternatively you can also use config-map.yaml given in sample


Creating AWS Credentials Secret
This Kubernetes Secret named aws-credentials is used to store AWS credentials and configuration data, enabling your Tekton Tasks to interact with AWS services securely.

Secret Structure:
credentials: Contains the AWS access key ID and secret access key for both a specified profile and the default profile.
config: Contains AWS region and output format settings for both a specified profile and the default profile.
Refer to secret.yaml in samples

Create the Secret:
Apply the Secret in your Kubernetes cluster:
kubectl apply -f secret.yaml
or
kubectl create secret generic aws-credentials --from-literal=access-key-id=<YOUR_ACCESS_KEY_ID> --from-literal=secret-access-key=<YOUR_SECRET_ACCESS_KEY>


Using the Secret in Tekton Tasks:
Reference the aws-credentials Secret in your Tekton Task to inject the AWS credentials and configuration:



