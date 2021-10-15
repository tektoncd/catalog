# GitHub Pull Request Merge SHA

GitHub Pull Request Merge SHA is Task for perform fetching `merge_commit_sha` -- a [test merge commit](https://docs.github.com/en/rest/reference/pulls#get-a-pull-request) from Pull Request event. For more information, please follow [this link](https://docs.github.com/en/rest/guides/getting-started-with-the-git-database-api#checking-mergeability-of-pull-requests).

## GitHub token

This task expects a secret set in the kubernetes secret `github`
with a GitHub token in the key `token`; you can easily create it on the
command line with `kubectl` like this :

```
kubectl create secret generic github --from-literal token="MY_TOKEN"
```

## Fetch Merge SHA from Pull Request

The `github-pr-mergeable-sha` task uses the [pull request api](https://docs.github.com/en/rest/reference/pulls#get-a-pull-request)
to fetch the `merge_commit_sha` and emit it as the result.

Since it [might not be available](https://docs.github.com/en/rest/guides/getting-started-with-the-git-database-api#checking-mergeability-of-pull-requests) at the webhook events, this task had `RETRY` and `BACKOFF_MS` parameters to control retry and backoff before failing the task.

### Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/github-pr-mergeable-sha/0.1/github-pr-mergeable-sha.yaml
```

### Parameters

* **REPO_FULL_NAME**: The GitHub repository full name, _e.g:_ `tektoncd/catalog`
* **GITHUB_HOST_URL**: The GitHub host domain _default:_ `api.github.com`
* **API_PATH_PREFIX**: The GitHub Enterprise has a prefix for the API path. _e.g:_ `/api/v3`
* **GITHUB_PULL_REQUEST_NUMBER**: The pull request number _e.g_: `1000`
* **GITHUB_TOKEN_SECRET_NAME** \[optional\]: The name of the kubernetes secret that
  contains the GitHub token. Default value: `github`
* **GITHUB_TOKEN_SECRET_KEY** \[optional\]: The key within the kubernetes secret that
  contains the GitHub token. Default value: `token`
* **RETRY** \[optional\]: The number of retry
* **BACKOFF_MS** \[optional\]: The backoff duration between retry (in ms)

### Results
* **commit-merge-sha**: The _test_ merge commit

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
    tekton.dev/task: github-pr-mergeable-sha
  name: github-pr-mergeable-sha-run-for-pr-842
spec:
  taskRef:
    kind: Task
    name: github-pr-mergeable-sha
  params:
    - name: REPO_FULL_NAME
      value: tektoncd/catalog
    - name: GITHUB_PULL_REQUEST_NUMBER
      value: "842"
```