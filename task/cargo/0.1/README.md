# Cargo
This task can be used to execute cargo commands for rust projects. It uses the docker hub rust image per default, but you can provide your own if needed.

## Install the task
```bash
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/cargo/0.1/cargo.yaml
```

## Parameters
* **COMMAND**
  * **description**: The cargo command to be executed. e.g. `build`
  * **type**: string
  * **default**: `build`
* **COMPILE_FLAGS** 
  * **description**: The flags passed to the command. e.g. `--release`
  * **type**: array
  * **default**: `[]`
* **CARGO_IMAGE** 
  * **description**: The image to use. e.g. `docker.io/rust:1.52`
  * **type**: string
  * **default**: `docker.io/rust@sha256:ea81624bfff9a2d46fc181532acdeafda3cf8c31d25536d443ef902d4894f72a`

## Workspaces
* **source**
  * **description**: Workspace containing the source code and cargo.toml

## Example usage
The following pipeline downloads a project from git using the git-clone task, and builds the project with release flag.

1. Pipeline:
```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: cargo-pipeline
spec:
  workspaces:
    - name: source
      description: The workspace that contains your cargo.toml and rust code. 
  params:
    - name: GIT_URI
      type: string
      description: The git url that contains your source code.
    - name: COMPILE_FLAGS
      type: array
      default: []
  tasks:
    - name: git-clone
      taskRef:
        name: git-clone
      workspaces:
        - name: output
          workspace: source
      params:
        - name: url
          value: '$(params.GIT_URI)'
    - name: cargo-build
      taskRef:
        name: cargo
      params:
        - name: COMPILE_FLAGS
          value: ['$(params.COMPILE_FLAGS[*])']
      runAfter:
        - git-clone
      workspaces:
        - name: source
          workspace: source
```

2. PipelineRun:

```yaml
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: cargo-build-release-run
spec:
  pipelineRef:
    name: cargo-pipeline
  workspaces:
  - name: source
    volumeClaimTemplate:
      spec:
        accessModes:
          - ReadWriteOnce
        resources:
          requests:
            storage: 128Mi
  params:
    - name: GIT_URI
      value: https://github.com/robertlemmens/rust-hello-world.git
    - name: COMPILE_FLAGS
      value: 
        - "--release"
```
