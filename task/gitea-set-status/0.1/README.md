# Gitea Set Status

Gitea Set Status is for updating the status of a commit. See the Gitea API documentation
for more information about it's usage at [Gitea API](https://try.gitea.io/api/swagger).

## Gitea token

This task expects a secret set in the kubernetes secret `gitea`
with a Gitea access token in the key `token`; you can easily create it on the
command line with `kubectl` like this :

```
kubectl create secret generic gitea --from-literal token="MY_ACCESS_TOKEN"
```

## Set Status on a Commit/PR

The `gitea-set-status` task uses the [commit status api](https://try.gitea.io/api/swagger)
to mark Gitea commits with an `error`, `failure`, `pending`, `warning` or `success`
state, which is then reflected in pull requests and commit history involving those commits.

Statuses include as well a `description` and a `target_url`, to give the user
informations about the CI statuses or a direct link to the full log.

### Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/gitea-set-status/0.1/raw
```

### Parameters

* **REPO_FULL_NAME**: The Gitea repository full name, _e.g:_ `tektoncd/catalog`
* **GITEA_HOST_URL**: The Gitea host, _e.g:_ `git.yourcompany.com`
* **GITEA_HTTPS_OR_HTTP**: If we should connect with HTTP or HTTPS. Use `http` or `https` here. _default:_ `https`
* **API_PATH_PREFIX**: The API path prefix of Gitea, _default:_ `/api/v1`
* **SHA**: The commit SHA to set the status for _e.g_: `tektoncd/catalog`
* **TARGET_URL**: The target URL to associate with this status. This URL will
  be linked from the Gitea UI to allow users to easily see the source of the
  status. For example you can link to a
  [dashboard](https://github.com/tektoncd/dashboard) URL so users can follow a
  Pipeline/Task run.
* **DESCRIPTION**: A short description of the status. _e.g:_ `Building your PR`
* **CONTEXT**: The Gitea context, A string label to differentiate this status
  from the status of other systems. _e.g:_ `continuous-integration/tekton`
* **STATE**: The state of the status. Can be one of the following `error`,
  `failure`, `pending`, `warning` or `success`.
* **GITEA_TOKEN_SECRET_NAME** \[optional\]: The name of the kubernetes secret that
  contains the Gitea token. Default value: `gitea`.
* **GITEA_TOKEN_SECRET_KEY** \[optional\]: The key within the kubernetes secret that
  contains the Gitea token. Default value: `token`.
* **IMAGE** \[optional\]: Image providing the python binary which this task uses. Default
  value: `3.10.1-alpine3.15`, the smallest python image.
* **SHEBANG** \[optional\]: The shebang relevant for the image. Default value: `/usrb/bin/env python`.


### Platforms

The Task can be run on any platform supporting a python image. The default image runs on `linux/386`
`linux/amd64`, `linux/arm/v6`, `linux/arm/v7`, `linux/arm64/v8`, `linux/ppc64le`, `linux/s390x`.

## Example usage

This TaskRun sets a commit on Gitea to `pending` getting tested by the CI.

```yaml
---
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  labels:
    tekton.dev/task: gitea-set-status
  name: gitea-set-status-run-on-commit-bd93
spec:
  taskRef:
    kind: Task
    name: gitea-set-status
  params:
    - name: REPO_FULL_NAME
      value: tektoncd/catalog
    - name: GITEA_HOST_URL
      value: gitea.com
    - name: SHA
      value: bd93869b489258cef567ccf85e7ef6bc0d6949ea
    - name: DESCRIPTION
      value: "Build has started"
    - name: STATE
      value: pending
    - name: TARGET_URL
      value: https://tekton/dashboard/taskrun/log
```
