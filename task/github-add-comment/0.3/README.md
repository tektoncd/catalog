# Add a comment to an issue or a pull request

The `github-add-comment` task let you add a comment to a pull request or an
issue.

## Changelog

- `Optional Workspace` support is added so that if you want to pass a file
  which contains the comment then it can be passed via workspace.
  (Use Case can be after running the CI you want to output the logs as
  a part of the CI.)
- Parameter `COMMENT` has been changed to `COMMENT_OR_FILE` in which user can
  provide the filename in case comments are present inside some file or you can
  directly pass the comments as well.

## Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/github-add-comment/0.3/raw
```

## Secrets

This Task requires access to a GitHub token set via a Kubernetes Secret. By default, the name of this Secret should be `github` and the secret key should be `token`, but you can configure this via the `GITHUB_TOKEN_SECRET_NAME` and `GITHUB_TOKEN_SECRET_KEY` [parameters](#parameters) described below.

To create such a Secret via `kubectl`:

```
kubectl create secret generic github --from-literal token="MY_TOKEN"
```

Check [this](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line) to get personal access token for `Github`.

See GitHub's documentation on [Understanding scopes for OAuth Apps](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/) to figure out what scopes you need to give to this token to add comment to an issue or a pull request.

## Parameters

- **GITHUB_HOST_URL:**: The GitHub host domain (_default:_ `api.github.com`)
- **API_PATH_PREFIX:**: The GitHub Enterprise has a prefix for the API path. _e.g:_ `/api/v3`
- **REQUEST_URL:**: The GitHub pull request or issue url, _e.g:_
  `https://github.com/tektoncd/catalog/issues/46`
- **COMMENT_OR_FILE:**: The actual comment to add or the filename inside the
  optional workspace `comment-file` containing comment to post. _e.g:_ `don't forget to eat your vegetables before commiting.` _or_ `input.txt`
- **GITHUB_TOKEN_SECRET_NAME**: The name of the Kubernetes Secret that
  contains the GitHub token. (_default:_ `github`).
- **GITHUB_TOKEN_SECRET_KEY**: The key within the Kubernetes Secret that contains the GitHub token. (_default:_ `token`).

## Workspaces

- **comment-file**: The optional workspace containing comment file to be posted.

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

This TaskRun add a comment to an issue.

```yaml
---
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  labels:
    tekton.dev/task: github-add-comment
  name: github-add-comment-to-pr-22
spec:
  taskRef:
    kind: Task
    name: github-add-comment
  params:
    - name: REQUEST_URL
      value: https://github.com/chmouel/scratchpad/pull/46
    - name: COMMENT_OR_FILE
      value: |
        The cat went here and there
        And the moon spun round like a top,
        And the nearest kin of the moon,
        The creeping cat, looked up.
        Black Minnaloushe stared at the moon,
        For, wander and wail as he would,
        The pure cold light in the sky
        Troubled his animal blood.
```

### When passing a comment via file

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: comment-cm
data:
  input.txt: |
    This is the sample input comment via file.
---
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  labels:
    tekton.dev/task: github-add-comment
  name: github-add-comment-to-pr-22
spec:
  taskRef:
    kind: Task
    name: github-add-comment
  workspace:
    - name: comment-file
      configMap:
        name: comment-cm
  params:
    - name: REQUEST_URL
      value: https://github.com/chmouel/scratchpad/pull/46
    - name: COMMENT_OR_FILE
      value: "input.txt"
```
