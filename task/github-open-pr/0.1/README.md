# GitHub Open Pull Request

GitHub Open Pull Request is part of a collection of GitHub tasks to help working
with the [GitHub API](https://docs.github.com/en/rest/reference).

## GitHub token

This task expects a secret set in the kubernetes secret `github`
with a GitHub token in the key `token`; you can easily create it on the
command line with `kubectl` like this :

```
kubectl create secret generic github --from-literal token="MY_TOKEN"
```

## Open Pull Request

The `github-open-pr` task uses the [pull request api](https://docs.github.com/en/rest/reference/pulls#create-a-pull-request)
to open pull requests on Github. It is able to fill in a title and body of the pull request.


### Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/github-open-pr/0.1/raw
```

### Parameters

* **GITHUB_HOST_URL**: The GitHub host domain _default:_ `api.github.com`
* **REPO_FULL_NAME**: The GitHub repository full name, _e.g:_ `tektoncd/catalog`
* **API_PATH_PREFIX**: The GitHub Enterprise has a prefix for the API path. _e.g:_ `/api/v3`
* **HEAD**: The name of the branch where your changes are implemented. _e.g.: `new-feature-i-created`
* **BASE**: The name of the branch you want the changes pulled into. _e.g.: `develop`
* **BODY**: The body description of the pull request. _e.g.: `The following PR includes these changes...`
* **TITLE**: The title of the pull request. _e.g.: `Feature X`
* **AUTH_TYPE**: The type of authentication to use. You could use the less secure "Basic"
      for example. See https://docs.github.com/en/rest/overview/other-authentication-methods for more information.
* **GITHUB_TOKEN_SECRET_NAME** \[optional\]: The name of the kubernetes secret that
  contains the GitHub token. Default value: `github`
* **GITHUB_TOKEN_SECRET_KEY** \[optional\]: The key within the kubernetes secret that
  contains the GitHub token. Default value: `token`

### Results

- **NUMBER**: Number of the created pull request.
- **URL**: URL of the created pull request.

### Platforms

The Task can be run on `linux/amd64`, `linux/s390x` and `linux/ppc64le` platforms.

## Usage for Bearer authentication

This TaskRun opens a pull request on GitHub.

```yaml
---
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: github-open-pr-from-develop-to-main
  labels:
    tekton.dev/task: github-open-pr
spec:
  taskRef:
    kind: Task
    name: github-open-pr
  params:
    - name: REPO_FULL_NAME
      value: tektoncd/catalog
    - name: HEAD
      value: develop
    - name: BASE
      value: main
    - name: TITLE
      value: "Feature X"
    - name: BODY
      value: "Includes the following changes"
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
  generateName: github-open-pr-from-develop-to-main
  labels:
    tekton.dev/task: github-open-pr
spec:
  taskRef:
    kind: Task
    name: github-open-pr
  params:
    - name: REPO_FULL_NAME
      value: tektoncd/catalog
    - name: HEAD
      value: develop
    - name: BASE
      value: main
    - name: TITLE
      value: "Feature X"
    - name: BODY
      value: "Includes the following changes"
    - name: AUTH_TYPE
      value: Basic
```
