---
name: code-review
description: >-
  Review a pull request or code change in tektoncd/catalog. Use when asked to
  review a PR, evaluate a diff, or assess code quality. Applies Tekton community
  standards, TEP-0003 catalog organization, task authoring recommendations, and
  catalog-specific conventions (directory structure, metadata, tests).
license: Apache-2.0
metadata:
  project: tekton-catalog
allowed-tools: Read Grep Glob Bash(git diff:*) Bash(git log:*) Bash(yamllint:*)
---

# Code Review

tektoncd/catalog follows [Tekton community review standards](https://github.com/tektoncd/community/blob/main/standards.md)
and [TEP-0003 Catalog Organization](https://github.com/tektoncd/community/blob/master/teps/0003-tekton-catalog-organization.md).

## Review Checklist

### Catalog Organization (TEP-0003)

- [ ] File path follows `<kind>/<name>/<version>/name.yaml` (kind = task, stepaction, or pipeline)
- [ ] Resource YAML file name matches the resource name
- [ ] `README.md` exists at `<kind>/<name>/<version>/README.md`
- [ ] `OWNERS` file exists at `<kind>/<name>/OWNERS` (or version-level)
- [ ] Version directory name is a valid semver-like format (e.g. `0.1`, `0.2`)

### Mandatory Metadata

- [ ] Label `app.kubernetes.io/version` matches the directory version
- [ ] Annotation `tekton.dev/pipelines.minVersion` is present and accurate
- [ ] Annotation `tekton.dev/categories` is present (e.g. Git, Build, Deploy, CLI)
- [ ] Annotation `tekton.dev/tags` is present with comma-separated tags
- [ ] Annotation `tekton.dev/displayName` is present (optional but recommended)
- [ ] Annotation `tekton.dev/platforms` lists supported platforms (optional)
- [ ] `spec.description` follows the convention: one-line summary followed by
  detailed paragraph(s)

### Task Authoring Quality

- [ ] **No `$(params.*)` interpolation inside `script` blocks** — this is a
  security vulnerability (code injection) and reliability issue. Parameters
  must be passed via `env` or `args` and referenced as `$ENV_VAR` or `$1`.
  See [recommendations.md](../../../recommendations.md)
- [ ] Images are referenced by digest (`image@sha256:...`) where possible,
  not by mutable tags (`:latest`)
- [ ] Steps run as non-root and non-privileged unless explicitly required.
  If root is needed, use `securityContext.runAsUser: 0` explicitly
- [ ] Parameters have default values where reasonable
- [ ] Workspaces have clear descriptions. Tasks should use **at most one
  writeable workspace** (Tekton recommendation)
- [ ] Script steps use `#!/usr/bin/env bash` (or appropriate shebang)
  with `set -e` for error handling
- [ ] No hardcoded values that should be parameters
- [ ] Results are documented and used only for small data (commit SHAs,
  branch names). Large data should use a Workspace instead
- [ ] Tasks are idempotent — safe to re-execute
- [ ] `tekton.dev/pipelines.minVersion` is set to the lowest version that
  supports the features used (portability across Pipeline versions)

### YAML Quality

- [ ] `yamllint` passes with the project's `.yamllint` config
- [ ] No trailing whitespace
- [ ] Consistent indentation (2 spaces)
- [ ] Proper quoting of strings where needed

### Testing

- [ ] New tasks or changed functionality include tests in `tests/` directory
- [ ] Test directory contains `run.yaml` (TaskRun or PipelineRun)
- [ ] Pre-apply hook scripts (`pre-apply-task-hook.sh`,
  `pre-apply-taskrun-hook.sh`) are used where setup is needed
- [ ] For tasks calling external APIs, fixtures are provided in
  `tests/fixtures/` for go-rest-api-test
- [ ] Tests do not depend on external services without fixture mocking

### New Version Workflow

- [ ] If bumping a version (e.g. 0.1 to 0.2), the old version was
  copied first in a separate commit, then modified in a subsequent commit
- [ ] Changes from the previous version are clearly visible in the diff
  (not buried in a full copy)

### Documentation

- [ ] `README.md` documents all parameters with types and defaults
- [ ] `README.md` documents all workspaces
- [ ] `README.md` documents all results (if any)
- [ ] `README.md` includes usage example(s)
- [ ] `samples/` directory contains example TaskRun/PipelineRun YAMLs

### Security

- [ ] **No `$(params.*)` interpolation in scripts** — critical injection risk
  (repeat check — this is the most common security issue in catalog tasks)
- [ ] No secrets or credentials hardcoded in YAML
- [ ] Sensitive data passed via Kubernetes Secrets or workspaces
- [ ] Container images come from trusted registries
- [ ] No use of `privileged: true` without justification

## What to Approve

Approve when:
- All checklist items pass
- Tests cover the changed behavior
- The change is focused (one concern per PR)
- Commit messages follow [Tekton commit conventions](https://github.com/tektoncd/community/blob/main/standards.md#commit-messages)
- New version workflow is followed (copy + modify in separate commits)

## What to Block

Block (request changes) when:
- `$(params.*)` is used inside `script` blocks (injection vulnerability)
- TEP-0003 structure is not followed
- Mandatory metadata labels/annotations are missing
- Images use mutable tags without justification
- Tests are missing for new or changed tasks
- Security issues (hardcoded secrets, unnecessary privileges)
- `yamllint` fails
- Version copy and modifications are squashed into a single commit
