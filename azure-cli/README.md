# `az`

This task performs operations on Microsoft Azure resources using `az`.

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/azure-cli/azure_cli.yaml
```

## Parameters

* **az-image**: `az` CLI container image to run this task.

  _default_: `mcr.microsoft.com/azure-cli:2.0.77`

  You can use a specific version of the `az` CLI by specifying the `az-image` param with the `mcr.microsoft.com/azure-cli` image tagged with the specific version of the CLI you would like to use (i.e. version 2.0.70 = `mcr.microsoft.com/azure-cli:2.0.70`). A full list of available version tags can be found under the [Full Tag Listing](https://hub.docker.com/_/microsoft-azure-cli) section of the `az` Docker Hub.

* **ARGS**: The arguments to pass to `az` CLI. This parameter is required to run this task.

## Usage

### Running the Task

After creating the task, you should now be able to execute `az` commands by specifying the command you would like to run as the `ARGS` param. The `ARGS` param takes an array of `az` subcommands that will be executed as part of this task.

### Examples

Run `az ad --help` using `az`. Start the task using the Tekton CLI (`tkn`):

```shell
tkn task start az -p ARGS=ad,--help
```

Specify a different `az-image` to use with the `az` task:

```shell
tkn task start az -p az-image=mcr.microsoft.com/azure-cli:2.0.70
```
