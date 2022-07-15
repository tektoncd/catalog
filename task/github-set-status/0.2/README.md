# GitHub Set Status

GitHub Set Status is part of a collection of GitHub tasks to help working
with the [GitHub API](https://docs.github.com/en/rest/reference).

## GitHub token

This task expects a secret set in the kubernetes secret `github`
with a GitHub token in the key `token`; you can easily create it on the
command line with `kubectl` like this :

```
kubectl create secret generic github --from-literal token="MY_TOKEN"
```

## Set Status on a Commit/PR

The `github-set-status` task uses the [status api](https://docs.github.com/en/rest/reference/repos#statuses)
to mark GitHub commits with an `error`, `failure`, `pending`, or `success`
state, which is then reflected in pull requests involving those commits.

Statuses include as well a `description` and a `target_url`, to give the user
informations about the CI statuses or a direct link to the full log.

### Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/github-set-status/0.2/raw
```

### Parameters

* **REPO_FULL_NAME**: The GitHub repository full name, _e.g:_ `tektoncd/catalog`
* **GITHUB_HOST_URL**: The GitHub host domain _default:_ `api.github.com`
* **API_PATH_PREFIX**: The GitHub Enterprise has a prefix for the API path. _e.g:_ `/api/v3`
* **SHA**: The commit SHA to set the status for _e.g_: `tektoncd/catalog`
* **TARGET_URL**: The target URL to associate with this status. This URL will
  be linked from the GitHub UI to allow users to easily see the source of the
  status. For example you can link to a
  [dashboard](https://github.com/tektoncd/dashboard) URL so users can follow a
  Pipeline/Task run.
* **DESCRIPTION**: A short description of the status. _e.g:_ `Building your PR`
* **CONTEXT**: The GitHub context, A string label to differentiate this status
  from the status of other systems. _e.g:_ `continuous-integration/tekton`
* **STATE**: The state of the status. Can be one of the following `error`,
  `failure`, `pending`, or `success`.
* **AUTH_TYPE**: The type of authentication to use. You could use the less secure "Basic"
      for example. See https://docs.github.com/en/rest/overview/other-authentication-methods for more information.
* **GITHUB_TOKEN_SECRET_NAME** \[optional\]: The name of the kubernetes secret that
  contains the GitHub token. Default value: `github`
* **GITHUB_TOKEN_SECRET_KEY** \[optional\]: The key within the kubernetes secret that
  contains the GitHub token. Default value: `token`

### Platforms

The Task can be run on `linux/amd64`, `linux/s390x` and `linux/ppc64le` platforms.

## Usage for Bearer authentication

This TaskRun sets a commit on GitHub to `pending` getting tested by the CI.

```yaml
---
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  labels:
    tekton.dev/task: github-set-status
  name: github-set-status-run-on-commit-bd93
spec:
  taskRef:
    kind: Task
    name: github-set-status
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
      value: https://tekton/dashboard/taskrun/log
```


## Usage for Basic authentication

Make sure the token is fabricated by base64 encoding the username and password with a semicolon in between.
Example shell script to use:

```bash
#!/bin/bash
echo "${1}:${2}" | base64
```

Calling this script like this `./script.sh githubuser reallyinsecurepassword` would result in `Z2l0aHVidXNlcjpyZWFsbHlpbnNlY3VyZXBhc3N3b3JkCg==`.

Place the result in a secret in the way as the token-based authenticaton.

The following TaskRun shows the usage of Basic authentication. Adding the `AUTH_TYPE` parameter.

```yaml
---
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  labels:
    tekton.dev/task: github-set-status
  name: github-set-status-run-on-commit-bd93
spec:
  taskRef:
    kind: Task
    name: github-set-status-with-basic-auth
  params:
    - name: REPO_FULL_NAME
      value: tektoncd/catalog
    - name: SHA
      value: bd93869b489258cef567ccf85e7ef6bc0d6949ea
    - name: DESCRIPTION
      value: "Build has started"
    - name: STATE
      value: pending
    - name: AUTH_TYPE
      value: Basic
    - name: TARGET_URL
      value: https://tekton/dashboard/taskrun/log
```
