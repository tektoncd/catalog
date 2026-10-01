# syft

This task allows the use of the syft for Tekton Pipelines. See <https://github.com/anchore/syft>

## What's Syft?

A CLI tool and Go library for generating a Software Bill of Materials (SBOM) from container images and filesystems. Exceptional for vulnerability detection when used with a scanner tool like Grype.
For more detail, please [see](https://github.com/anchore/syft).

## Parameters

* **SYFT_IMAGE**: Optional address of the syft container image to be used for task.

  _default_: "docker.io/anchore/syft:v0.35.1@sha256:fd2da1424585680f220ed61db13096f7abcd0c0073b52616bbce397a8e708a96"

* **ARGS**: The arguments to pass to `syft` CLI. This parameter is required to run this task.

### Examples

Run `syft --help` for Syft usage.

Using the [Tekton CLI](https://github.com/tektoncd/cli/blob/main/docs/cmd/tkn_task_start.md) (`tkn`):

```shell
tkn task start syft -p ARGS="--help"
```

Generate SBOM for Alpine image:

```shell
tkn task start syft -p ARGS="docker.io/alpine:3.13"
```

## Platforms

The Task can be run on `linux/amd64` and `linux/arm64` platforms.
