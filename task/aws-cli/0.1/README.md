# aws

This task performs operations on Amazon Web Services resources using `aws`.

All aws cli commands can be found [here](https://docs.aws.amazon.com/cli/latest/reference/).

## Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/aws-cli/0.1/raw
```

## Parameters

- **SCRIPT**: The script of aws commands to execute e.g. `aws $1 $2` This will take
 the first value and second value of ARGS as `s3` and `ls` (default: `aws $@`)
- **ARGS**: The arguments to pass to `aws` CLI, which are appended
    to `aws` e.g. `s3 ls` ( default: `["help"]` ).


## Workspaces

- **source**: To mount file which is to be uploaded to the aws resources,
    this should be mounted using any volume supported in workspace.
- **secrets**: A workspace that consists of credentials required by the `aws` which needs to be mounted to their default path as required by the aws.


## Secret

AWS `credentials` and `config` both should be provided in the form of `secret`.

[This](../0.1/samples/secret.yaml) example can be referred to create `aws-credentials`.

Refer [this](https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/setup-credentials.html) guide for setting up AWS Credentials and Region.

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

After creating the task, you should now be able to execute `aws` commands by
specifying the command you would like to run as the `ARGS` or `SCRIPT` param.

The `ARGS` param takes an array of aws subcommands that will be executed as
part of this task and the `SCRIPT` param takes the multiple commands that you would like to run on aws CLI.

This [samples](../0.1/samples/secret.yaml), can be referred to create secret file for aws credentials.

In the [samples](../0.1/samples/run.yaml), ConfigMap as the volume is used. In place of ConfigMap, any volume supported in workspace can be used.

Following `command` can be used to create `ConfigMap` from the `file`.
```
kubectl create configmap upload-file --from-file=demo.zip
```
Here `upload-file` is the name of the `ConfigMap`, this can be changed based on the requirements.

See [here](../0.1/samples/run.yaml) for example of `aws s3` command.


### Note


- Either `SCRIPT` or `ARGS` must be provided in the `params` of the task.

- To support multiple `aws` commands to run on a single task, SCRIPT can be used as follows:

  ```yaml
  - name: SCRIPT
    value: |
      aws s3 mb s3://test-bucket
      aws s3api put-object --bucket test-bucket --key test/
      aws s3 cp $(workspaces.source.path)/demo.zip s3://test-bucket/test/demo.zip
  ```

- In case there is no requirement of file that is to be uploaded on the aws resources,
 then `emptyDir` needs to be mounted in the `workspace` as shown below:
    ```
    workspaces:
      - name: source
        emptyDir: {}
    ```
    otherwise, if `Volume(e.g. ConfigMap) is needed:

    ```yaml
    workspaces:
      - name: source
        configmap:
            name: upload-file
    ```
