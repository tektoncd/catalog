# Mypy Linter for Python

`Mypy` is an optional `static type checker` for `Python` that aims to combine the benefits of dynamic (or "duck") typing and static typing. `Mypy` combines the expressive power and convenience of Python with a powerful type system and compile-time type checking. `Mypy` type checks standard Python programs; run them using any Python VM with basically no runtime overhead.

The following task is used to provide static analysis on python files mounted using `mypy` (Python linter).

## Installing the Task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/mypy-lint/0.1/raw
```

## Parameters

- **args**: The extra params along with the file path needs to be provided as the part of `args`. (_Default_: `["--help"]`)

## Workspaces

- **shared-workspace**: The workspace containing files on which we want to apply linter check. It can be a shared workspace with the `git-clone` task or a `ConfigMap` mounted containing some files.

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

1. Create the `git-clone` task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/git-clone/0.1/raw
```

2. Create the PVC
3. Apply the required tasks

4. Create the Pipeline and PipelineRun for `Python` linter

```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: linter-pipeline
spec:
  workspaces:
    - name: shared-workspace
  tasks:
    - name: fetch-repository
      taskRef:
        name: git-clone
      workspaces:
        - name: output
          workspace: shared-workspace
      params:
        - name: url
          value: https://github.com/vinamra28/tekton-linter-test
        - name: revision
          value: "linter-test"
        - name: subdirectory
          value: ""
        - name: deleteExisting
          value: "true"
    - name: mypy-lint-run #lint python
      taskRef:
        name: mypy-lint
      runAfter:
        - fetch-repository
      workspaces:
        - name: shared-workspace
          workspace: shared-workspace
      params:
        - name: args
          value: ["python.py"]

---
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: linter-pipeline-run
spec:
  pipelineRef:
    name: linter-pipeline
  workspaces:
    - name: shared-workspace
      persistentvolumeclaim:
        claimName: linter-pvc
```

**NOTE**: Pipeline will go into `failed` state if the linter check fails.
