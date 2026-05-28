---
name: debugging-e2e-failures
description: >-
  Diagnose and fix failed e2e tests in tektoncd/catalog. Use when a CI run
  fails, a local test hangs, or a TaskRun/PipelineRun reaches an error state.
  Covers triage from GitHub Actions output to root cause, common failure
  patterns, and local reproduction.
license: Apache-2.0
metadata:
  project: tekton-catalog
allowed-tools: Read Grep Glob Bash(kubectl:*) Bash(git:*) Bash(kind:*) Bash(docker:*) Bash(gh:*)
---

# Debugging e2e Test Failures

## Triage Workflow

### Step 1: Identify which matrix leg failed

CI runs e2e tests against multiple Tekton Pipeline versions. Check the GitHub
Actions summary to find which version(s) failed:

```bash
# From a PR, list failed checks
gh pr checks <PR-number> | grep -i fail

# Or view a specific workflow run
gh run view <run-id> --log-failed
```

The matrix legs are:
- `latest` / `lts-latest` → Pipeline v1.9.0
- `lts-latest-minus-one` → Pipeline v1.6.0
- `lts-latest-minus-two` → Pipeline v1.3.0
- `lts-latest-minus-three` → Pipeline v1.0.0

If the failure is only on older Pipeline versions, the task likely uses a
feature not available in that version. Check `tekton.dev/pipelines.minVersion`.

### Step 2: Find the failing task

The CI log will show lines like:

```
STARTING: <task-name>/<version>
FAILED: <task-name> task has failed to comeback properly
```

Search the log for `FAILED:` or `ERROR` to locate the failing task.

### Step 3: Read the diagnostic dump

When a test fails, `show_failure()` in `test/e2e-common.sh` dumps:
- All TaskRuns (YAML) in the test namespace
- All PipelineRuns (YAML)
- All pod container logs
- API resources

Look for:
- `.status.conditions[].reason` on the TaskRun/PipelineRun
- Container logs from `step-*` containers
- Events showing scheduling or image pull issues

### Step 4: Reproduce locally

```bash
# Minimal Kind cluster with Tekton
kind create cluster --name debug-catalog
kubectl apply -f https://github.com/tektoncd/pipeline/releases/download/v1.0.0/release.yaml
kubectl wait --for=condition=ready pod -l app=tekton-pipelines-controller \
  -n tekton-pipelines --timeout=60s

# Run the failing test
./test/run-test.sh task <task-name> <version>
```

To match a specific CI matrix leg, use the matching Pipeline version:

```bash
kubectl apply -f https://github.com/tektoncd/pipeline/releases/download/<version>/release.yaml
```

## Common Failure Patterns

### TaskRun stuck in Pending

```bash
kubectl describe taskrun <name> -n <namespace>
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
```

Causes:
- **Missing workspace PVC**: the test needs a `pre-apply-taskrun-hook.sh` to
  create a PVC or use `emptyDir`
- **Missing Secret/ConfigMap**: check if the test references resources that
  the hook should create
- **Resource quota**: unlikely in Kind, but check node resources

### ImagePullBackOff

```bash
kubectl describe pod <pod> -n <namespace> | grep -A5 "Events:"
```

Causes:
- **Digest changed**: the image was rebuilt upstream and the pinned digest
  is stale. Update the digest in the task YAML
- **Registry rate limit**: docker.io pulls are rate-limited. The Kind setup
  uses a pull-through cache at `registry.local:5000`, but it can fail if
  the cache is cold
- **Typo in image reference**: check the `image:` field carefully

### Script failure (exit code non-zero)

```bash
kubectl logs <pod> -n <namespace> -c step-<step-name>
```

Causes:
- **Missing tool in image**: the script calls a binary not in the container
- **Parameter interpolation bug**: if `$(params.*)` is used in a `script`
  block, values with special characters will break the shell
- **Network issue**: the script tries to reach an external service. Use
  fixtures instead (see below)

### Fixture/mock API failures

If the task uses `tests/fixtures/` for API mocking:

```bash
# Check the go-rest-api-test sidecar logs
kubectl logs <pod> -n <namespace> -c go-rest-api
```

Causes:
- **Path mismatch**: the fixture rule path doesn't match what the task
  actually calls. The sidecar logs show incoming requests
- **Method mismatch**: POST vs GET vs PATCH
- **Missing fixture rule**: a new API call was added but no fixture covers it

### Timeout (10 minute limit)

The test runner polls for 60 iterations of 10 seconds (10 minutes total).
If a TaskRun takes longer, it times out.

```bash
# Check what's still running
kubectl get taskrun -n <namespace> -o wide
kubectl get pods -n <namespace>
```

Causes:
- **Waiting for input**: the script has an interactive prompt or `read`
- **Deadlock on workspace**: two steps writing to the same file
- **Slow image pull**: large images on a cold Kind cluster cache
- **Infinite loop in script**: check the step logs for repeated output

### test_yaml_can_install failure

This happens before any TaskRun is created — the Task YAML itself is invalid:

```
ERROR: task <name> can't be installed
```

Causes:
- **Invalid YAML syntax**: run `yamllint -c .yamllint <file>`
- **Unknown API field**: using a field from a newer Tekton version than
  the CI leg is testing against
- **Duplicate resource name**: another task with the same `metadata.name`

## Iterating Without Full Teardown

```bash
# Delete the test namespace and retry
kubectl delete ns <task>-<version> --ignore-not-found
./test/run-test.sh task <task-name> <version>

# Or just re-apply the task and re-run the TaskRun
kubectl delete taskrun --all -n <namespace>
kubectl delete task <task-name> -n <namespace>
kubectl apply -f task/<task-name>/<version>/<task-name>.yaml -n <namespace>
kubectl apply -f task/<task-name>/<version>/tests/run.yaml -n <namespace>
```

## Cleanup

```bash
kind delete cluster --name debug-catalog
docker network prune -f
```
