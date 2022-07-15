# ansible-builder cli

This task creates a [build context](https://ansible-builder.readthedocs.io/en/latest/usage/#the-create-command) (including a Containerfile) from an execution environment spec. The tasks just executes `ansible-builder create` so the build context is populated with dependencies including requirements files.

It takes an execution environment definition as an input and outputs the build context necessary for building an execution environment image. However, the create command will not build the execution environment image; this is useful for creating just the build context and a Containerfile that can then be shared.

It means a further task that works with Dockerfile/Containerfile such as `buildah` or `kaniko` should be added to a pipeline in order to build (and push) the execution environment container image.

## Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/ansible-builder/0.1/raw
```

## Parameters

* **FILENAME:** Execution environment file definition. (_default:_ `execution-environment.yml`)

* **BUILD_CONTEXT:** Execution environment build context. (_default:_ `context`)

* **OUTPUT_FILENAME:** Name of the file to write the image definition to. Either `Dockerfile` or `Containerfile`. (_default:_ `Containerfile`)

* **VERBOSITY:** ansible-builder output verbosity. (_default:_ `2`)

* **BUILDER_IMAGE:** The location of the ansible-builder image. (_default:_ `quay.io/ansible/ansible-builder:latest`)

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

This sample `Pipeline` fetches the repo, creates the execution environment context using `ansible-builder` task and then uses `buildah` task to build the execution environment container image and push it to a registry.

[Pipeline with ansible-builder](./samples/1-pipeline.yaml)

**NOTE:**
This example has been tested in OpenShift 4.9, assuming the `PipelineRun` is executed by the `pipeline` Service Account,
and that Service Account has enough permissions to pull and push any container image used in within the pipeline.
