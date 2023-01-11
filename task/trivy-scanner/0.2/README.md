# trivy-scanner

This task allows the use of the Trivy vulneralability scanner for Tekton Pipelines. See <https://github.com/aquasecurity/trivy>

## What's Trivy?

Trivy (tri pronounced like trigger, vy pronounced like envy) is a simple and comprehensive scanner for vulnerabilities in container images, file systems, and Git repositories, as well as for configuration issues. Trivy detects vulnerabilities of OS packages (Alpine, RHEL, CentOS, etc.) and language-specific packages (Bundler, Composer, npm, yarn, etc.). In addition, Trivy scans Infrastructure as Code (IaC) files such as Terraform, Dockerfile and Kubernetes, to detect potential configuration issues that expose your deployments to the risk of attack. Trivy is easy to use. Just install the binary and you're ready to scan

## Parameters

* **TRIVY_IMAGE**: Optional address of the trivy container image to be used for task.

  _default_: "docker.io/aquasec/trivy@sha256:dea76d4b50c75125cada676a87ac23de2b7ba4374752c6f908253c3b839201d9"

* **ARGS**: The arguments to pass to `trivy` CLI. This parameter is required to run this task.

* **IMAGE_PATH**: The image or path to pass to `trivy` CLI for scanning. This parameter is required to run this task.

* **AIR_GAPPED_ENABLED**: Optional parameter for enabling/disabling air-gapped mode, disabled by default. If set to true, the task will use the Trivy's air-gapped mode. You can learn more about the Air-Gapped installation support of the Trivy from [here](https://aquasecurity.github.io/trivy/v0.36/docs/advanced/air-gap/).

### Examples

Run `trivy --help` for Trivy usage.

Using the [Tekton CLI](https://github.com/tektoncd/cli/blob/main/docs/cmd/tkn_task_start.md) (`tkn`):

```shell
tkn task start trivy-scanner -p ARGS="--help" -p IMAGE_PATH="" -p AIR_GAPPED_ENABLED="true" --workspace name=manifest-dir,emptyDir=""
```

Scan Alpine Image:

```shell
tkn task start trivy-scanner -p ARGS="image,--exit-code,0" -p IMAGE_PATH="docker.io/alpine:3.13" -p AIR_GAPPED_ENABLED="true" --workspace name=manifest-dir,emptyDir=""
```

For Pipeline Example See <https://github.com/MoOyeg/trivy-tekton-example>

## Platforms

The Task can be run on `linux/amd64` platform.