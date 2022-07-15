# GitLab Set Status

GitLab Set Status is part of a collection of GitLab tasks to help working
with the [GitLab API](https://docs.gitlab.com/ee/api/).

## Set Status on a Commit/MR

The `gitlab-set-status` task uses the [commit api](https://docs.gitlab.com/ee/api/commits.html#post-the-build-status-to-a-commit)
to mark GitLab commits with a `pending`,`running`, `success`, `failed`, or `canceled` state, which is then reflected in merge requests involving those commits.

Statuses include as well a `description` and a `target_url`, to give the user
informations about the CI statuses or a direct link to the full log.

### Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/gitlab-set-status/0.1/raw
```

### Parameters
* **STATE**: The state of the status. Can be one of the following `pending`, `running`, `success`, `failed`, or `canceled`.
* **GITLAB_TOKEN_SECRET_NAME**: The name of the kubernetes secret that contains the GitLab access token. _default:_ `gitlab-api-secret`
* **GITLAB_TOKEN_SECRET_KEY**: The key within the kubernetes secret that contains the GitLab token, _default:_ `token`
* **SHA**: The commit SHA to set the status for
* **TARGET_URL**: The target URL to associate with this status. This URL will
  be linked from the GitLab UI to allow users to easily see the source of the
  status. For example you can link to a
  [dashboard](https://github.com/tektoncd/dashboard) URL so users can follow a
  Pipeline/Task run.
* **GITLAB_HOST_URL**: The GitLab host domain _default:_ `gitlab.com`
* **API_PATH_PREFIX**: The GitLab Enterprise has a prefix for the API path. _default:_ `/api/v4`
* **REPO_FULL_NAME**: The GitLab repository full name, _default:_ `tektoncd/catalog`
* **DESCRIPTION**: A short description of the status. _e.g:_ `Building your MR`
* **CONTEXT**: The GitLab context, A string label to differentiate this status
  from the status of other systems. _e.g:_ `continuous-integration/tekton`

## Platforms

The Task can be run on `linux/amd64` platform.