# grype

This task allows the use of the grype for Tekton Pipelines.
## What's Grype?

A vulnerability scanner for container images and filesystems. Easily install the binary to try it out. Works with Syft, the powerful SBOM (software bill of materials) tool for container images and filesystems.
For more detail, please [see](https://github.com/anchore/grype).

## Parameters

* **GRYPE_IMAGE**: Optional address of the grype container image to be used for task.

  _default_: "docker.io/anchore/grype@sha256:84ec572a9d39e6c4774cbaf5678e73c772d394651c6cdee1c21f74203ff68685"

* **ARGS**: The arguments to pass to `grype` CLI. This parameter is required to run this task.

### Examples

Run `grype --help` for Grype usage.

Using the [Tekton CLI](https://github.com/tektoncd/cli/blob/main/docs/cmd/tkn_task_start.md) (`tkn`):

```shell
tkn task start grype -p ARGS="--help" --workspace name=source-dir,emptyDir=""
```

Scan Alpine Image:

```shell
tkn task start grype -p ARGS="docker.io/alpine:3.13" --workspace name=source-dir,emptyDir=""
```

## Platforms

The Task can be run on `linux/amd64` and `linux/arm64` platforms.
