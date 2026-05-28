# Tekton Catalog

Curated collection of reusable Tekton Task, StepAction, and Pipeline YAML
manifests. Not a Go project — no `make build`. Go files exist only for
vendoring test-infrastructure dependencies.

## Build & Test

```bash
make setup                # one-command setup
make lint                 # yamllint + gofmt — must pass before every PR
make test TASK=git-clone VERSION=0.9   # single-task e2e (needs cluster)
make test-e2e             # full CI suite (spins up Kind cluster)
```

## Directory Structure (TEP-0003)

```
task/<name>/<version>/<name>.yaml      # resource name = dir name = file name
task/<name>/<version>/README.md        # required
task/<name>/<version>/tests/run.yaml   # required for new/changed tasks
task/<name>/OWNERS                     # required
stepaction/<name>/<version>/...        # same layout
pipeline/<name>/...                    # same layout
```

## Critical Rules

1. **No `$(params.*)` in `script` blocks** — injection risk. Pass via `env`.
2. **Pin images by digest** (`@sha256:...`), not mutable tags.
3. **Version bumps**: copy old version in one commit, modify in the next.
4. **Metadata required**: `app.kubernetes.io/version` label,
   `tekton.dev/pipelines.minVersion` annotation, `spec.description`.

## Skills

Detailed conventions, checklists, and workflows live in `.claude/skills/`:

- **task-authoring** — scaffold tasks, bump versions, full metadata checklist
- **code-review** — PR review against TEP-0003, security, and quality standards
- **running-tests** — yamllint, gofmt, single-task e2e, full CI e2e
- **commit-message** — conventional commits, DCO sign-off, line limits
- **debugging-e2e-failures** — triage CI failures, reproduce locally, common error patterns

## References

- [Authoring recommendations](recommendations.md)
- [TEP-0003 Catalog Organization](https://github.com/tektoncd/community/blob/master/teps/0003-tekton-catalog-organization.md)
- [Tekton commit conventions](https://github.com/tektoncd/community/blob/main/standards.md#commit-messages)
- Canonical example: `task/git-clone/0.9/`
