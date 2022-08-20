## GitHub Create Deployment

The `github-create-deployment` Task lets you create a GitHub deployment.

See GitHub's deployment API on [Create a deployment](https://docs.github.com/rest/reference/repos#create-a-deployment) for more information.

### Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/github-create-deployment/0.2/raw
```

### Secrets

This Task requires access to a GitHub token set via a Kubernetes Secret. By default, the name of this Secret should be `github` and the secret key should be `token`, but you can configure this via the `GITHUB_TOKEN_SECRET_NAME` and `GITHUB_TOKEN_SECRET_KEY` [parameters](#parameters) described below.

To create such a Secret via `kubectl`:

```
kubectl create secret generic github --from-literal token="MY_TOKEN"
```

Token must have `repo_deployment` scope to create deployments. See GitHub's documentation on [Scopes for OAuth Apps](https://docs.github.com/developers/apps/scopes-for-oauth-apps) for details.

### Parameters

- **GITHUB_HOST_URL**: The GitHub host domain. (_default:_ `api.github.com`)
- **API_PATH_PREFIX**: The GitHub Enterprise has a prefix for the API path. (_e.g.:_ `/api/v3`)
- **REPO_FULL_NAME**: The GitHub repository full name. (_e.g.:_ `tektoncd/catalog`)
- **REF**: The ref to deploy. This can be a branch, tag, or SHA. (_e.g.:_ `main`)
- **TASK**: Specifies a task to execute. (_default:_ `deploy`)
- **AUTO_MERGE**: Attempts to automatically merge the default branch into the
  requested ref, if it's behind the default branch. (_default:_ `true`)
- **REQUIRED_CONTEXTS**: The status contexts to verify against commit status checks. To
  verify all unique contexts before creating a deployment, pass
  in `*`. To bypass checking entirely, pass an empty string. (_default:_ `*`)
- **PAYLOAD**: JSON payload with extra information about the deployment. (_default:_ `""`)
- **ENVIRONMENT**: Name for the target deployment environment (_e.g.:_ `production`).
- **DESCRIPTION**: Short description of the deployment. (_default:_ `""`).
- **GITHUB_TOKEN_SECRET_NAME**: The name of the Kubernetes Secret that
  contains the GitHub token. (_default:_ `github`).
- **GITHUB_TOKEN_SECRET_KEY**: The key within the Kubernetes Secret that contains the GitHub token. (_default:_ `token`).

### Results

- **ID**: ID of the created deployment.
- **URL**: URL of the created deployment.
- **STATUSES_URL**: URL of the created deployment status.

### Platforms

The Task can be run on `linux/amd64`, `linux/s390x` and `linux/ppc64le` platforms.

## Usage

This TaskRun creates a GitHub deployment for the given repository.

```yaml
---
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  labels:
    tekton.dev/task: github-create-deployment
  name: github-create-tektoncd-catalog-deployment
spec:
  taskRef:
    kind: Task
    name: github-create-deployment
  params:
    - name: REPO_FULL_NAME
      value: tektoncd/catalog
    - name: REF
      value: main
    - name: ENVIRONMENT
      value: staging
```
