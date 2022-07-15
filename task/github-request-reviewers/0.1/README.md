# Request reviewers on a pull request

The `github-request-reviewers` task lets one request reviewers on a pull request. It implements the corresponding [GitHub API](https://docs.github.com/en/rest/reference/pulls#request-reviewers-for-a-pull-request) to request reviewers.

## Changelog

- v0.1: Initial version.

## Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/github-request-reviewers/0.1/raw
```

## Secrets

This Task requires access to a GitHub token. The token is expected to be in a workspace, which will typically be bound to Kubernetes Secret at run time. The name of the file in the workspace is `token` by default, but it can be configured via the `github-token-key` parameter from the [parameters](#parameters) described below.

To create such a Secret via `kubectl`:

```
kubectl create secret generic github --from-literal token="MY_TOKEN"
```

Check [this](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line) to get personal access token for `Github`.

Requesting reviewers only requires the `public_repo` scope for the token. See GitHub's documentation on
[Understanding scopes for OAuth Apps](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/)
for more details.

## Parameters

- **GITHUB_HOST_URL:**: The GitHub host domain (_default:_ `api.github.com`)
- **API_PATH_PREFIX:**: The GitHub Enterprise has a prefix for the API path. _e.g:_ `/api/v3` (_default:_ "").
- **PACKAGE:**: The GitHub {org}/{repo}, _e.g:_ `tektoncd/catalog`
- **PULL_REQUEST_NUMBER:**: The GitHub pull request or issue url, _e.g:_ `1234`
- **REVIEWERS:**: Comma separated list of github user slugs _e.g:_ `user1,user2` (_default:_ "").
- **TEAM_REVIEWERS**: Comma separated list of github user slugs (_default:_ "").
- **GITHUB_TOKEN_FILE**: The name of the file in the workspace that contains the github token. (_default:_ `token`).

## Workspaces

- **github**: The workspace that contains the github token

### Platforms

The Task can be run on `linux/amd64`, `linux/s390x` and `linux/ppc64le` platforms.

## Usage

This TaskRun requests both users and teams as reviewers:

```yaml
---
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  generateName: github-request-reviewers-
spec:
  taskRef:
    kind: Task
    name: github-request-reviewers
  workspace:
    - name: github
      secret:
        secretName: "bot-token-github"
  params:
    - name: PACKAGE
      value: tektoncd/catalog
    - name: PULL_REQUEST_NUMBER
      value: "1234"
    - name: REVIEWERS
      value: "user1,user2"
    - name: TEAM_REVIEWERS
      value: "team1,team2"
```
