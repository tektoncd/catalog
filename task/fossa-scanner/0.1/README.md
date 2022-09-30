# fossa-scanner

- fossa-cli is a zero-configuration polyglot dependency analysis tool. You can point fossa CLI at any codebase or build, and it will automatically detect dependencies being used by your project.
- This task can be used to scan for dependency analysis, license scanning, vulnerability scanning, 
    attribution report generation, and more on the source code in standalone mode.

## Background

- fossa analyzes complex codebases to generate dependency reports and license notices. It can generate fast and highly-accurate results, by leveraging existing build environments. Refer to the FOSSA CLI User Manual for in depth information about using this tool.
- Features:
  - Supports over 20+ languages & environments (JavaScript, Java, Ruby, Python, Golang, PHP, .NET, etc...)
  - Autoconfigures for monoliths; instantly handles multiple builds in large codebases.
  - Fast & portable; a cross-platform binary you can drop into CI or dev machines.
  - Generates offline documentation for license notices & third-party attributions.
  - Tests dependencies against license violations, audits and vulnerabilities (coming soon!) by integrating with https://fossa.com

### Install the Docker Build Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/docker-build/0.1/raw
```

### Parameters

* **FOSSA_ENDPOINT**: Optional address of fossa server endpoint.

  _default_: "https://fossa.com/"

* **FOSSA_API_KEY**: The arguments to pass to `fossa` CLI. This parameter is required to run this task.

* **FOSSACLI_IMAGE**: The image or path which has `fossa` CLI. This parameter is required to run this task.

  _default_: "docker.io/nistal97/fossa-cli@sha256:b3dd65d1297e9436b9e0f176c355ea1fa9c6295d09f79032c830b6e7e3376293"

* **FOSSA_TELEMETRY_SCOPE**: The arguments to pass to `fossa` CLI. This parameter is required to run this task.

* **TEAM**: The arguments to pass to `fossa` CLI. This parameter is required to run this task.

### Example

An example `TaskRun` with PersistentVolumeClaim workspace can be found in the subdirectory `test`.

## Platforms

The Task can be run on `linux/amd64` platform.
