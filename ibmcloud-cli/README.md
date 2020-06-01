# `ibmcloud`

This task performs operations on IBM Cloud using the `ibmcloud`

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/ibmcloud-cli/ibmcloud-cli.yaml
```

## Parameters

* **ibmcloud-image**: `ibmcloud` CLI container image to run this task.

  _default_: `ibmcom/ibm-cloud-developer-tools-amd64:latest`

  You can use a specific version of the `ibmcloud` CLI by specifying the `ibmcloud-image` param with the `ibmcom/ibm-cloud-developer-tools-amd64` image tagged with the specific version of the CLI you would like to use.  A full list of available version tags can be found under the [Full Tag Listing](https://hub.docker.com/r/ibmcom/ibm-cloud-developer-tools-amd64/tags) section of the `ibm-cloud-developer-tools-amd64` Docker Hub.

* **ARGS**: The arguments to pass to `ibmcloud` CLI. This parameter is required to run this task.

## Usage

### Running the Task

After creating the task, you should now be able to execute `ibmcloud` commands by specifying the command you would like to run as the `ARGS` param. The `ARGS` param takes an array of `ibmcloud` subcommands that will be executed as part of this task.

### Examples

Run `ibmcloud ks --help` using `ibmcloud`. Start the task using the Tekton CLI (`tkn`):

```shell
tkn task start ibmcloud -p ARGS=ks,--help
```

Specify a different `ibmcloud-image` to use with the `ibmcloud` task:

```shell
tkn task start ibmcloud -p ibmcloud-image=ibmcom/ibm-cloud-developer-tools-amd64:1.1.0
```
