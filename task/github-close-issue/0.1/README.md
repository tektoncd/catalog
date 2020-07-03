# GitHub

A collection of tasks to help working with the [GitHub
API](https://developer.github.com/v3/).

## GitHub token

Most tasks would expect to have a secret set in the kubernetes secret `github`
with a GitHub token in the key `token`, you can easily create it on the
command line with `kubectl` like this :

```
kubectl create secret generic github --from-literal token="MY_TOKEN"
```

## Close an issue or a pull request

The `github-close-issue` task let you close a pull request or an
issue.

### Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/task/github-close-issue/0.1/github-close-issue.yaml
```

### Parameters

* **GITHUB_HOST_URL:**: The GitHub host domain (_default:_ `api.github.com`)
* **API_PATH_PREFIX:**: The GitHub Enterprise has a prefix for the API path. _e.g:_ `/api/v3`
* **REQUEST_URL:**: The GitHub pull request or issue url, (_e.g:_
  `https://github.com/tektoncd/catalog/issues/46`)

## Usage

This TaskRun close an issue on a task.

```yaml
---
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  labels:
    tekton.dev/task: github-close-issue
  name: github-close-issue-to-pr-46
spec:
  taskRef:
    kind: Task
    name: github-close-issue
  params:
    - name: REQUEST_URL
      value: https://github.com/chmouel/scratchpad/pull/46
```
