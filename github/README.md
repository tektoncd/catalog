# GitHub

A collection of tasks to help working with the [GitHub
API](https://developer.github.com/v3/).

## GitHub token

Most tasks would expect to have a secret set in the github secret `github-secret`
with a GitHub token in the key `secretToken`, you can easily create it on the
command line :

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

* **REPO_FULL_NAME:**: The GitHub repository full name, e.g: _tektoncd/catalog_
* **GITHUB_HOST_URL:**: The GitHub host domain (_default:_ `api.github.com`)
* **SHA:**: The commit SHA to set the status for i.e: _tektoncd/catalog_
* **TARGET_URL:**: The target URL to associate with this status. This URL will
  be linked from the GitHub UI to allow users to easily see the source of the
  status. For example you can link to a
  [dashboard](https://github.com/tektoncd/dahsboard) URL so users can follow a
  Pipeline/Task run.
* **DESCRIPTION:**: A short description of the status. e.g: _"Building your PR"_
* **CONTEXT:** The GitHub context, A string label to differentiate this status
  from the status of other systems. e.g: `"continuous-integration/tekton"`
* **STATE:** The state of the status. Can be one of the following `error`,
  `failure`, `pending`, or `success`.

## Usage

This TaskRun runs the Task to set a successfull status on a commit

```
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
