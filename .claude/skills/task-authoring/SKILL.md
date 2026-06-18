---
name: task-authoring
description: >-
  Create a new Tekton Task or add a new version of an existing task in
  tektoncd/catalog. Use when the user wants to scaffold a new task, bump a
  task version, or add a task that already exists elsewhere into the catalog.
  Covers TEP-0003 directory structure, mandatory metadata, README, OWNERS,
  tests, and the copy-then-modify versioning workflow.
license: Apache-2.0
metadata:
  project: tekton-catalog
allowed-tools: Read Grep Glob Bash(git:*) Bash(kubectl:*) Bash(yamllint:*)
---

# Task Authoring

## Workflow 1: Create a Brand New Task

### 1. Scaffold the directory

```bash
mkdir -p task/<task-name>/0.1/tests
mkdir -p task/<task-name>/0.1/samples
```

### 2. Create the Task YAML

File: `task/<task-name>/0.1/<task-name>.yaml`

The file name **must match** the task name.

```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: <task-name>
  labels:
    app.kubernetes.io/version: "0.1"
  annotations:
    tekton.dev/pipelines.minVersion: "0.17.0"
    tekton.dev/categories: <category>
    tekton.dev/tags: <tag1>, <tag2>
    tekton.dev/displayName: "<Human Readable Name>"
    tekton.dev/platforms: "linux/amd64"
spec:
  description: >-
    One-line summary of what this task does.

    Detailed paragraph(s) explaining the task, its inputs,
    outputs, and any prerequisites.

  params:
    - name: PARAM_NAME
      type: string
      description: What this parameter controls
      default: "sensible-default"

  workspaces:
    - name: source
      description: Workspace containing the source code.

  results:
    - name: result-name
      description: What this result contains.

  steps:
    - name: step-name
      image: <image>@sha256:<digest>
      env:
        - name: PARAM_NAME
          value: $(params.PARAM_NAME)
      script: |
        #!/usr/bin/env bash
        set -e
        echo "$PARAM_NAME"
```

#### Mandatory checklist

- [ ] `metadata.name` matches the file name and directory name
- [ ] `app.kubernetes.io/version` label matches directory version (`"0.1"`)
- [ ] `tekton.dev/pipelines.minVersion` — lowest Tekton Pipelines version needed
- [ ] `tekton.dev/categories` — one of: Git, Build Tools, CLI, Cloud, Deploy,
      Security, Testing, Monitoring, Messaging, Automation, etc.
- [ ] `tekton.dev/tags` — comma-separated descriptive tags
- [ ] `spec.description` — one-line summary + detailed paragraph
- [ ] Images use digest references (`@sha256:...`) not mutable tags
- [ ] Steps run as non-root (no `securityContext.runAsUser: 0` unless required)
- [ ] Parameters passed via `env` or `args`, **never** interpolated in `script`

#### Security: Parameter passing

**WRONG** — injection risk:

```yaml
script: |
  echo $(params.MESSAGE)
```

**CORRECT** — use env vars:

```yaml
env:
  - name: MESSAGE
    value: $(params.MESSAGE)
script: |
  echo "$MESSAGE"
```

### 3. Create the README

File: `task/<task-name>/0.1/README.md`

Follow this structure (see `task/maven/0.3/README.md` as example):

```markdown
# <Task Name>

One-line description of what this task does.

## Install the Task

kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/<task-name>/0.1/<task-name>.yaml

## Parameters

- **PARAM_NAME**: Description (_default_: `value`)

## Workspaces

- **source**: Description of what goes in this workspace

## Results

- **result-name**: Description

## Platforms

The Task can be run on `linux/amd64` platforms.

## Usage

(Include a TaskRun example)
```

### 4. Create the OWNERS file

File: `task/<task-name>/OWNERS` (at the task level, not version level)

```yaml
approvers:
  - <github-username>
reviewers:
  - <github-username>
```

### 5. Create tests

File: `task/<task-name>/0.1/tests/run.yaml`

Minimum: a TaskRun that exercises the task's primary functionality.

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: <task-name>-run
spec:
  taskRef:
    name: <task-name>
  params:
    - name: PARAM_NAME
      value: "test-value"
  workspaces:
    - name: source
      emptyDir: {}
```

#### Optional test hooks

If your task needs setup before running:

`task/<task-name>/0.1/tests/pre-apply-task-hook.sh`:

```bash
#!/bin/bash
# Runs before the Task is applied
# Example: install a dependency task
add_task git-clone latest
```

`task/<task-name>/0.1/tests/pre-apply-taskrun-hook.sh`:

```bash
#!/bin/bash
# Runs before the TaskRun is applied
# Example: create a PVC, Secret, or ConfigMap
kubectl create -f task/<task-name>/0.1/tests/resources.yaml
```

#### Fixtures for external API tasks

If your task calls an external REST API, create fixture rules in
`task/<task-name>/0.1/tests/fixtures/`:

```yaml
---
headers:
  method: POST
  path: /api/v1/resource
response:
  status: 200
  output: '{"status": "ok"}'
  content-type: text/json
```

Then override the API URL parameter in your TaskRun to point to
`http://localhost:8080` — the test runner spins up a go-rest-api-test
sidecar automatically when it finds a `fixtures/` directory.

### 6. Create samples

File: `task/<task-name>/0.1/samples/<task-name>-run.yaml`

A ready-to-use TaskRun example users can copy.

### 7. Validate

```bash
# YAML lint
yamllint -c .yamllint task/<task-name>/

# Verify task is valid Kubernetes YAML
kubectl apply --dry-run=client -f task/<task-name>/0.1/<task-name>.yaml

# Run the e2e test (requires a cluster with Tekton)
./test/run-test.sh task <task-name> 0.1
```

---

## Workflow 2: Add a New Version of an Existing Task

### 1. Copy the old version (separate commit)

```bash
cp -a task/<task-name>/<old-version> task/<task-name>/<new-version>
git add task/<task-name>/<new-version>
git commit -m "chore(<task-name>): copy task from <old-version> to <new-version>"
```

**This must be its own commit** — it keeps the git diff clean so reviewers
see only your actual changes, not the entire file copy.

### 2. Make your changes (separate commit)

Edit the files in `task/<task-name>/<new-version>/`:

- Update `app.kubernetes.io/version` label to match new version
- Make your feature/fix changes
- Update README.md
- Update tests if needed

```bash
git add task/<task-name>/<new-version>
git commit -m "feat(<task-name>): <description of changes>"
```

### 3. Validate

```bash
yamllint -c .yamllint task/<task-name>/<new-version>/
./test/run-test.sh task <task-name> <new-version>
```

---

## Workflow 3: Add an Existing Task from Elsewhere

If a task already exists outside the catalog (e.g., in another repo) and
you want to bring it into tektoncd/catalog:

1. Follow Workflow 1 (create new task) — do not just copy the file
2. Ensure it meets all catalog conventions (metadata, tests, README)
3. Adapt image references to use digests
4. Remove any `$(params.*)` interpolation in scripts — use env vars
5. Add proper OWNERS file with the maintainer(s)
6. Verify `tekton.dev/pipelines.minVersion` is accurate

---

## Reference: Complete Directory Structure

```
task/<task-name>/
  OWNERS                          # required: maintainers
  <version>/
    <task-name>.yaml              # required: task definition
    README.md                     # required: documentation
    samples/                      # recommended: usage examples
      <task-name>-run.yaml
    tests/                        # required for new tasks
      run.yaml                    # TaskRun or PipelineRun
      pre-apply-task-hook.sh      # optional: pre-task setup
      pre-apply-taskrun-hook.sh   # optional: pre-run setup
      resources.yaml              # optional: PVCs, Secrets, etc.
      fixtures/                   # optional: API mock rules
        rules.yaml
```

## Reference: Canonical Examples

| What | Example path |
|------|-------------|
| Simple task | `task/git-clone/0.9/` |
| Task with test hooks | `task/maven/0.3/` |
| Task with fixtures | `task/github-add-comment/0.1/` |
| Task with sidecar registry | `task/kaniko/0.6/` |
| StepAction | `stepaction/git-clone/0.1/` |
| Pipeline | `pipeline/build-push-gke-deploy/` |
