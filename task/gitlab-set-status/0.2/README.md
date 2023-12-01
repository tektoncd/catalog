# GitLab Set Status

GitLab Set Status is part of a collection of GitLab tasks to help working
with the [GitLab API](https://docs.gitlab.com/ee/api/).

## Set Status on a Commit/MR

The `gitlab-set-status` task uses the [commit api](https://docs.gitlab.com/ee/api/commits.html#post-the-build-status-to-a-commit)
to mark GitLab commits with a `pending`,`running`, `success`, `failed`, or `canceled` state, which is then reflected in merge requests involving those commits.

Statuses include as well a `description`, a `target_url` and a `coverage`, to give the user
informations about the CI statuses or a direct link to the full log.

### Install the Task

```shell
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/gitlab-set-status/0.2/raw
```

### Parameters

* **STATE** (string): The state of the status. Can be one of the following `pending`, `running`, `success`, `failed`, or `canceled`.
* **GITLAB_TOKEN_SECRET_NAME** (string, optional): The name of the kubernetes secret that contains the GitLab access token. _default:_ `gitlab-api-secret`
* **GITLAB_TOKEN_SECRET_KEY** (string, optional): The key within the kubernetes secret that contains the GitLab token. _default:_ `token`
* **SHA** (string): The commit SHA to set the status for.
* **TARGET_URL** (string): The target URL to associate with this status. This URL will
  be linked from the GitLab UI to allow users to easily see the source of the
  status. For example you can link to a
  [dashboard](https://github.com/tektoncd/dashboard) URL so users can follow a
  Pipeline/Task run.
* **GITLAB_HOST_URL** (string, optional): The GitLab host domain. _default:_ `gitlab.com`
* **API_PATH_PREFIX** (string, optional): The GitLab Enterprise has a prefix for the API path. _default:_ `/api/v4`
* **REPO_FULL_NAME** (string, optional): The GitLab repository full name. _default:_ `tektoncd/catalog`
* **DESCRIPTION** (string): A short description of the status. _e.g:_ `Building your MR`
* **CONTEXT** (string, optional): The GitLab context, A string label to differentiate this status
  from the status of other systems. _e.g:_ `continuous-integration/tekton`
* **COVERAGE** (string, optional): The total code coverage. Should be a float string.  _default:_ `""`

## Platforms

The Task can be run on `linux/amd64` platform.
