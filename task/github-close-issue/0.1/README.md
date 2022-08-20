# Close an issue or a pull request

The `github-close-issue` task let you close a pull request or an
issue.

## Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/github-close-issue/0.1/raw
```

## Secrets

This tasks would expect to have a secret set in the kubernetes secret `github`
with a GitHub token in the key `token`, you can easily create it on the
command line with `kubectl` like this :

```
kubectl create secret generic github --from-literal token="MY_TOKEN"
```

Check [this](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line) to get personal access token for `Github`.

See GitHub's documentation on [Understanding scopes for OAuth Apps](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/) to figure out what scopes you need to give to this token to add comment to an issue or a pull request.

## Parameters

* **GITHUB_HOST_URL:**: The GitHub host domain (_default:_ `api.github.com`)
* **API_PATH_PREFIX:**: The GitHub Enterprise has a prefix for the API path. _e.g:_ `/api/v3`
* **REQUEST_URL:**: The GitHub pull request or issue url, (_e.g:_
  `https://github.com/tektoncd/catalog/issues/46`)

## Platforms

The Task can be run on `linux/amd64` platform.

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
