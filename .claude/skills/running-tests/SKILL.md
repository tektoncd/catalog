---
name: running-tests
description: >-
  Run linters, formatting checks, and e2e tests for tektoncd/catalog. Use when
  verifying a code change, preparing a PR, debugging a test failure, or checking
  overall project health. Covers yamllint, gofmt, single-task e2e via
  run-test.sh, and full CI e2e suite with Kind cluster.
license: Apache-2.0
compatibility: Requires yamllint, go, kubectl; e2e tests also require kind, ko, and a container runtime
metadata:
  project: tekton-catalog
allowed-tools: Bash(yamllint:*) Bash(gofmt:*) Bash(go test:*) Bash(./test/*) Bash(./hack/*) Bash(kubectl:*) Read Grep
---

# Running Tests

## Linting

### YAML Lint

All YAML files must pass yamllint with the project's `.yamllint` config:

```bash
# Lint all YAML files in the repo
yamllint -c .yamllint $(find . -type f -regex ".*y[a]ml" -print)

# Lint a specific task directory
yamllint -c .yamllint task/git-clone/0.9/

# Install yamllint if not present
pip install yamllint
```

The `.yamllint` config ignores `vendor/` and `hack/`, disables line-length
and document-start rules, and treats `truthy` and `comments` as warnings.

### Go Formatting

Go files (test infrastructure only) must be formatted:

```bash
# Check for formatting issues
gofmt -d $(find * -name '*.go' ! -path 'vendor/*' ! -path 'third_party/*')
```

If `gofmt` produces any diff, the CI will reject the PR.

## e2e Tests

### Single Task Test

Test a single task locally using the test runner script. Requires a running
Kubernetes cluster with Tekton Pipelines installed:

```bash
# Syntax: ./test/run-test.sh <kind> <name> <version>
./test/run-test.sh task git-clone 0.9
./test/run-test.sh task kaniko 0.6
./test/run-test.sh task buildah 0.7
```

The test runner:
1. Creates a random namespace
2. Applies the task YAML
3. Applies all YAML files in `<kind>/<name>/<version>/tests/`
4. Waits for TaskRun/PipelineRun completion
5. Reports pass/fail

**Note**: CI only tests tasks that were added or modified in the PR, unless
`TEST_RUN_ALL_TESTS` is set.

### Test Directory Structure

Each task version can have a `tests/` directory:

```
task/<name>/<version>/tests/
  run.yaml                      # TaskRun or PipelineRun to execute
  pre-apply-task-hook.sh        # optional: runs before applying the Task
  pre-apply-taskrun-hook.sh     # optional: runs before applying test YAMLs
  fixtures/                     # optional: go-rest-api-test rules
    rules.yaml
```

### Pre-Apply Hook Scripts

Hook scripts run via `source`, so they can export environment variables:

#### pre-apply-task-hook.sh

Runs before the Task is applied. Use for:
- Modifying the Task YAML for test purposes
- Setting up prerequisites in the namespace
- Creating ConfigMaps, Secrets, or other resources

#### pre-apply-taskrun-hook.sh

Runs before TaskRun/PipelineRun YAMLs are applied. Use for:
- Creating test resources (PVCs, Secrets)
- Setting up services (registries, mock APIs)
- Modifying TaskRun parameters

### Helper Functions

Available in hook scripts (sourced from plumbing):

| Function | Purpose |
|----------|---------|
| `add_sidecar_registry` | Adds a container registry sidecar for image builder tasks |
| `add_sidecar_secure_registry` | Adds a TLS-secured registry sidecar with cert ConfigMap |
| `add_task` | Installs another catalog task into the test namespace. Args: `<name> <version>` (use `latest` for latest version) |

### Fixtures-Based Testing

For tasks that call external REST APIs (e.g. GitHub, Jira), use
[go-rest-api-test](https://github.com/chmouel/go-rest-api-test) fixtures:

1. Create `tests/fixtures/` directory with YAML rules:

```yaml
---
headers:
  method: POST
  path: /repos/{repo:[^/]+/[^/]+}/issues/{issue:[0-9]+}/comments
response:
  status: 200
  output: '{"status": 200}'
  content-type: text/json
```

2. The test runner auto-detects the `fixtures/` directory and spins up a
   go-rest-api-test sidecar on `http://localhost:8080`

3. Override the API host URL parameter in your TaskRun:

```yaml
params:
  - name: GITHUB_HOST_URL
    value: http://localhost:8080
```

**Requirement**: The task must support overriding the API URL via a parameter.

## Full CI Suite

### Local Kind Cluster

Spin up a full CI-like environment locally:

```bash
./hack/setup-kind.sh \
  --registry-url registry.local:5000 \
  --cluster-suffix cluster.local \
  --nodes 1 \
  --pipeline-version v1.9.0 \
  --e2e-script ./test/e2e-tests.sh \
  --e2e-env ./test/e2e-tests-kind-gha.env
```

This script:
1. Creates a Kind cluster with a local registry
2. Installs Tekton Pipelines at the specified version
3. Runs the e2e test suite

### CI Pipeline

GitHub Actions (`.github/workflows/ci.yaml`) runs:

- **linting** job: `yamllint` + `gofmt`
- **e2e-tests** job: matrix of Tekton Pipeline versions:
  - `latest` (v1.9.0)
  - `lts-latest` (v1.9.0)
  - `lts-latest-minus-one` (v1.6.0)
  - `lts-latest-minus-two` (v1.3.0)
  - `lts-latest-minus-three` (v1.0.0)

### Replicating CI Locally

```bash
# Linting (always run before pushing)
yamllint -c .yamllint $(find . -type f -regex ".*y[a]ml" -print)
gofmt -d $(find * -name '*.go' ! -path 'vendor/*' ! -path 'third_party/*')

# Single task e2e (requires cluster)
./test/run-test.sh task <name> <version>
```

Both linting checks must pass before requesting a review.

## Interpreting Test Failures

- **yamllint failures**: Fix YAML formatting issues (indentation, trailing
  whitespace, truthy values)
- **gofmt failures**: Run `gofmt -w <file>` to auto-fix
- **e2e test timeout**: Check if the TaskRun is stuck — inspect pod logs
  with `kubectl logs` and events with `kubectl describe taskrun`
- **Pre-apply hook failures**: Check that all required tools are available
  in the test-runner image
- **Fixtures test failures**: Verify the fixture rules match the actual
  API calls made by the task

## Debugging Running TaskRuns

When a TaskRun is failing or stuck:

```bash
# List TaskRuns in the test namespace
kubectl get taskrun -n <namespace>

# Describe a specific TaskRun (shows conditions, events, pod name)
kubectl describe taskrun <name> -n <namespace>

# Get the pod created by the TaskRun
kubectl get pods -n <namespace> -l tekton.dev/taskRun=<name>

# Stream logs from a running step container
kubectl logs -n <namespace> <pod-name> -c step-<step-name> -f

# If pod is in Pending/ImagePullBackOff — check events
kubectl describe pod <pod-name> -n <namespace>

# Check if Tekton controller is healthy
kubectl get pods -n tekton-pipelines

# Get all events in namespace sorted by time
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
```

Common failure patterns:
- **Pending pod**: Usually a resource quota, missing PVC, or node scheduling issue
- **ImagePullBackOff**: Bad image reference — check digest/tag and registry access
- **step container OOMKilled**: Increase resource limits or reduce workload
- **Script exit code non-zero**: Read step logs for the actual error
- **Timeout**: TaskRun default timeout is 1h; check if the script is hung
  (e.g. waiting for input, network call blocked)

## Kind Cluster Lifecycle

### Setup

```bash
# Full setup with Tekton Pipelines (used by CI)
./hack/setup-kind.sh \
  --registry-url registry.local:5000 \
  --cluster-suffix cluster.local \
  --nodes 1 \
  --pipeline-version v1.9.0 \
  --e2e-script ./test/e2e-tests.sh \
  --e2e-env ./test/e2e-tests-kind-gha.env

# Minimal setup for local testing (just cluster + Tekton)
kind create cluster --name tekton-catalog-test
kubectl apply --filename https://github.com/tektoncd/pipeline/releases/download/v1.0.0/release.yaml
kubectl wait --for=condition=ready pod -l app=tekton-pipelines-controller -n tekton-pipelines --timeout=60s
```

### Teardown

```bash
# Delete the Kind cluster
kind delete cluster --name tekton-catalog-test

# If using the CI script's default cluster name
kind delete cluster --name tekton

# Clean up leftover Docker networks (if Kind didn't clean up)
docker network prune -f
```

### Iterating Without Full Teardown

When debugging a single task, you can reuse the cluster:

```bash
# Delete all TaskRuns in a namespace
kubectl delete taskrun --all -n <namespace>

# Delete and recreate just the task under test
kubectl delete task <name> -n <namespace>
kubectl apply -f task/<name>/<version>/<name>.yaml -n <namespace>

# Re-run the test
./test/run-test.sh task <name> <version>
```

## Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `PIPELINE_VERSION` | `v1.1.0` | Tekton Pipelines version for e2e tests |
| `KO_DOCKER_REPO` | _(required for Kind)_ | Image registry for ko builds |
| `TEST_RUN_ALL_TESTS` | _(unset)_ | Set to run tests for all tasks, not just changed ones |
| `MAX_NUMBERS_OF_PARALLEL_TASKS` | `3` | Max parallel e2e test tasks (0-indexed, so 3 = 4 parallel) |
