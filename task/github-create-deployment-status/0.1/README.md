## GitHub Create Deployment Status

The `github-create-deployment-status` Task lets you create a status for GitHub deployment.

See GitHub's deployment API on [Create a deployment status](https://docs.github.com/rest/reference/repos#create-a-deployment-status) for more information.

### Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/github-create-deployment-status/0.1/raw
```

### Secrets

This Task requires access to a GitHub token set via a Kubernetes Secret. By default, the name of this Secret should be `github` and the secret key should be `token`, but you can configure this via the `GITHUB_TOKEN_SECRET_NAME` and `GITHUB_TOKEN_SECRET_KEY` [parameters](#parameters) described below.

To create such a Secret via `kubectl`:

```
kubectl create secret generic github --from-literal token="MY_TOKEN"
```

Token must have `repo_deployment` scope to create deployment status. See GitHub's documentation on [Scopes for OAuth Apps](https://docs.github.com/developers/apps/scopes-for-oauth-apps) for details.

### Parameters

- **GITHUB_HOST_URL**: The GitHub host domain. (_default:_ `api.github.com`)
- **API_PATH_PREFIX**: The GitHub Enterprise has a prefix for the API path. (_e.g.:_ `/api/v3`)
- **REPO_FULL_NAME**: The GitHub repository full name. (_e.g.:_ `tektoncd/catalog`)
- **DEPLOYMENT_ID**: The ID of deployment. (_e.g.:_ `"1"`)
- **STATE**: The state of the status. This can be one of "error", "failure",
  "inactive", "in_progress", "queued", "pending" or "success". (_e.g.:_ `in_progress`)
- **LOG_URL**: The full URL of the deployment's output. (_default:_ `""`)
- **DESCRIPTION**: Short description of the status. (_default:_ `""`)
- **ENVIRONMENT**: Name for the target deployment environment. (_default:_ `""`)
- **ENVIRONMENT_URL**: The URL for accessing environment. (_default:_ `""`)
- **AUTO_INACTIVE**: Adds a new inactive status to all prior non-transient,
  non-production environment deployments with the same repository and
  environment name as the created status's deployment. (_default:_ `"true"`)
- **GITHUB_TOKEN_SECRET_NAME**: The name of the Kubernetes Secret that
  contains the GitHub token. (_default:_ `github`).
- **GITHUB_TOKEN_SECRET_KEY**: The key within the Kubernetes Secret that contains the GitHub token. (_default:_ `token`).

### Platforms

The Task can be run on `linux/amd64`, `linux/s390x` and `linux/ppc64le` platforms.

## Usage

This TaskRun creates a status for the given GitHub deployment.

```yaml
---
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  labels:
    tekton.dev/task: github-create-deployment-status
  name: github-create-tektoncd-catalog-deployment-status
spec:
  taskRef:
    kind: Task
    name: github-create-deployment-status
  params:
    - name: REPO_FULL_NAME
      value: tektoncd/catalog
    - name: DEPLOYMENT_ID
      value: "1"
    - name: STATE
      value: in_progress
```
