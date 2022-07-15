
# Close an issue or a pull request

The `github-close-issue` task let you close a pull request or an
issue.

## Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/github-close-issue/0.2/raw
```

## Secrets

This Task requires access to a GitHub token set via a Kubernetes Secret. By default, the name of this Secret should be `github` and the secret key should be `token`, but you can configure this via the `GITHUB_TOKEN_SECRET_NAME` and `GITHUB_TOKEN_SECRET_KEY` [parameters](#parameters) described below.

To create such a Secret via `kubectl`:

```
kubectl create secret generic github --from-literal token="MY_TOKEN"
```

Check [this](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line) to get personal access token for `Github`.

See GitHub's documentation on [Understanding scopes for OAuth Apps](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/) to figure out what scopes you need to give to this token to close an issue or a pull request.

## Parameters

* **GITHUB_HOST_URL:**: The GitHub host domain (_default:_ `api.github.com`)
* **API_PATH_PREFIX:**: The GitHub Enterprise has a prefix for the API path. _e.g:_ `/api/v3`
* **REQUEST_URL:**: The GitHub pull request or issue url, (_e.g:_
  `https://github.com/tektoncd/catalog/issues/46`)
* **GITHUB_TOKEN_SECRET_NAME**: The name of the Kubernetes Secret that
  contains the GitHub token. (_default:_ `github`).
* **GITHUB_TOKEN_SECRET_KEY**: The key within the Kubernetes Secret that contains the GitHub token. (_default:_ `token`).

## Platforms

The Task can be run on `linux/amd64`, `linux/s390x` and `linux/ppc64le` platforms.

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
