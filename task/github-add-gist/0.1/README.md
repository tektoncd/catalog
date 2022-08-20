# GitHub Add Gist

The following task lets you upload a file to `gist` GitHub
and outputs the raw url as the result.

## Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/github-add-gist/0.1/raw
```

## Secrets

This Task requires access to a GitHub token set via a Kubernetes Secret. By default, the name of this Secret should be `github` and the secret key should be `token`, but you can configure this via the `GITHUB_TOKEN_SECRET_NAME` and `GITHUB_TOKEN_SECRET_KEY` [parameters](#parameters) described below.

To create such a Secret via `kubectl`:

```
kubectl create secret generic github --from-literal token="MY_TOKEN"
```

Check [this](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line) to get personal access token for `Github`.

See GitHub's documentation on [Understanding scopes for OAuth Apps](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/) to figure out what scopes you need to give to this token to add comment to an issue or a pull request.

> Note: Make sure you have added `gist` scope while creating a personal access token.

## Parameters

- **GITHUB_HOST_URL:**: The GitHub host domain (_default:_ `api.github.com`)
- **API_PATH_PREFIX:**: The GitHub Enterprise has a prefix for the API path. _e.g:_ `/api/v3`
- **FILE_NAME:**: Name of the file to be uploaded to gist. _e.g:_ `catlin.txt`.
- **GITHUB_TOKEN_SECRET_NAME**: The name of the Kubernetes Secret that
  contains the GitHub token. (_default:_ `github`).
- **GITHUB_TOKEN_SECRET_KEY**: The key within the Kubernetes Secret that contains the GitHub token. (_default:_ `token`).


## Workspaces

- **input**: The input workspace which contains the file to be uploaded to gist.

### Platforms

The Task can be run on `linux/amd64`, `linux/s390x` and `linux/ppc64le` platforms.

## Usage

The following example will take a file from ConfigMap and
upload to gist.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: comment-cm
data:
  test.txt: |
    This is the sample input comment via file.
---
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  generateName: github-add-gist-
spec:
  taskRef:
    name: github-add-gist
  workspace:
    - name: input
      configMap:
        name: comment-cm
  params:
    - name: FILE_NAME
      value: "test.txt"
```
