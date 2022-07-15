# Scorecards

These tasks provides scorecard results based on the [OSSF Scorecards](https://github.com/ossf/scorecard) project.

## Install the Task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/scorecard/0.1/raw
```

## Parameters

- **REPO**: The url to the repository to inspect.
- **GITHUB-OAUTH_SECRET**: The name of the secret storing GitHub credentials. They should be in the `token` field.

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

This `TaskRun` runs `scorecard` on a repository:

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  generateName: scorecard-run-
spec:
  params:
  - name: REPO
    value: github.com/ossf/scorecard
  - name: GITHUB-OAUTH_SECRET
    value: github
  taskRef:
    kind: Task
    name: scorecard
```
