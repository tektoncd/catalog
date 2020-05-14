# GitLab

A collection of tasks to help working with the [GitLab API](https://docs.gitlab.com/ee/api/).

## GitLab token

Most tasks would expect to have a secret set in the kubernetes secret `gitlab`
with a GitLab token in the key `token`.
Check [this](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html) 
to get personal access token for `Gitlab`. 
You can easily create it on the command line with `kubectl` like this :

```
kubectl create secret generic github --from-literal token="MY_TOKEN"
```

or

```
apiVersion: v1
kind: Secret
metadata:
  name: gitlab
type: Opaque
stringData:
  token: $(personal_access_token)
```

## Add labels to an issue in Gitlab

[This task](../gitlab/issue-add-labels.yaml) can be used to add labels to the gitlab issue.


### Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/gitlab/issue-add-labels.yaml
```

### Parameters

- **GITLAB_HOST_URL**: The Gitlab host(_default:_`gitlab.com`).
- **API_PATH_PREFIX**: The API path prefix (_default.:_`api/v4`).
- **REQUEST_URL**: The Gitlab issue URL where we want to add labels (_e.g._`https://gitlab.com/foo/bar/issues/10`).
- **LABELS**: The actual labels to add.
- **GITLAB_TOKEN_SECRET**: The name of the `secret` holding the gitlab-token (_default:_`gitlab`).
- **GITLAB_TOKEN_SECRET_KEY**: The name of the `secret key` holding the gitlab-token (_default:_`token`).


### Secrets

* `Secret` to provide Gitlab `access token` to authenticate to the Gitlab.


### Usage


This task expects a secret named `gitlab` to exists, with a Gitlab token in `token` with enough privileges to add label to an issue.

To add labels to an issue, put all the required params, add required secrets and labels will be created.


`Taskrun` can be created as follows:

```
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: gitlab-add-label-run
spec:
  taskRef:
    name: gitlab-add-label
  params:
    - name: REQUEST_URL
      value: https://gitlab.com/Divyanshu42/aws-cli/-/issues/1
    - name: LABELS
      value: 
        - bug
        - kind/feature
```
