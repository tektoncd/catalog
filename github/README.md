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

## Set Status on a Commit/PR

The `github-set-status` task allows external services to mark GtiHUB commits
with an `error`, `failure`, `pending`, or `success` state, which is then
reflected in pull requests involving those commits.

Statuses include as well a `description` and a `target_url`, to give the user
informations about the CI statuses or a direct link to the full log.

### Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/github/set_status.yaml
```

### Inputs

#### Parameters

* **REPO_FULL_NAME:**: The GitHub repository full name, _e.g:_ `tektoncd/catalog`
* **GITHUB_HOST_URL:**: The GitHub host domain _default:_ `api.github.com`
* **API_PATH_PREFIX:**: The GitHub Enterprise has a prefix for the API path. _e.g:_ `/api/v3`
* **SHA:**: The commit SHA to set the status for _e.g_: `tektoncd/catalog`
* **TARGET_URL:**: The target URL to associate with this status. This URL will
  be linked from the GitHub UI to allow users to easily see the source of the
  status. For example you can link to a
  [dashboard](https://github.com/tektoncd/dahsboard) URL so users can follow a
  Pipeline/Task run.
* **DESCRIPTION:**: A short description of the status. _e.g:_ `Building your PR`
* **CONTEXT:** The GitHub context, A string label to differentiate this status
  from the status of other systems. _e.g:_ `continuous-integration/tekton`
* **STATE:** The state of the status. Can be one of the following `error`,
  `failure`, `pending`, or `success`.

## Usage

This TaskRun sets a commit on GitHub to `pending` getting tested by the CI.

```yaml
---
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  labels:
    tekton.dev/task: github-set-status
  name: github-set-status-run-on-commit-bd93
spec:
  taskRef:
    kind: Task
    name: github-set-status
  inputs:
    params:
      - name: REPO_FULL_NAME
        value: tektoncd/catalog
      - name: SHA
        value: bd93869b489258cef567ccf85e7ef6bc0d6949ea
      - name: DESCRIPTION
        value: "Build has started"
      - name: STATE
        value: pending
      - name: TARGET_URL
        value: https://tekon/dashboard/taskrun/log
```

## Add a comment to an issue or a pull request

The `github-add-comment` task let you add a comment to a pull request or an
issue.

### Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/github/add_comment.yaml
```

### Inputs

#### Parameters

* **GITHUB_HOST_URL:**: The GitHub host domain (_default:_ `api.github.com`)
* **API_PATH_PREFIX:**: The GitHub Enterprise has a prefix for the API path. _e.g:_ `/api/v3`
* **REQUEST_URL:**: The GitHub pull request or issue url, _e.g:_
  `https://github.com/tektoncd/catalog/issues/46`
* **COMMENT:**: The actual comment to add _e.g:_ `don't forget to eat your vegetables before commiting.`.

## Usage

This TaskRun add a comment to an issue.

```yaml
---
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  labels:
    tekton.dev/task: github-add-comment
  name: github-add-comment-to-pr-22
spec:
  taskRef:
    kind: Task
    name: github-add-comment
  inputs:
    params:
      - name: REQUEST_URL
        value: https://github.com/chmouel/scratchpad/pull/46
      - name: COMMENT
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

## Close an issue or a pull request

The `github-close-issue` task let you close a pull request or an
issue.

### Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/github/close_issue.yaml
```

### Inputs

#### Parameters

* **GITHUB_HOST_URL:**: The GitHub host domain (_default:_ `api.github.com`)
* **API_PATH_PREFIX:**: The GitHub Enterprise has a prefix for the API path. _e.g:_ `/api/v3`
* **REQUEST_URL:**: The GitHub pull request or issue url, (_e.g:_
  `https://github.com/tektoncd/catalog/issues/46`)

## Usage

This TaskRun close an issue on a task.

```yaml
---
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  labels:
    tekton.dev/task: github-close-issue
  name: github-close-issue-to-pr-46
spec:
  taskRef:
    kind: Task
    name: github-close-issue
  inputs:
    params:
      - name: REQUEST_URL
        value: https://github.com/chmouel/scratchpad/pull/46
```
