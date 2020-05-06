# Create Gitlab Release

It is typical to create a Gitlab tag at the moment of release to introduce a checkpoint in your source code history,
but in most cases users will need compiled objects or other assets output, not just the raw source code.

Gitlab Releases are a way to track deliverables in your project. Consider them a snapshot in time of the source,
build output, artifacts, and other metadata associated with a released version of your code.

This `task` can be used to make the `gitlab release`.

Task can also be used to upload `assets` including `binaries` of the released version, with the release.

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/gitlab/create-gitlab-release/create-gitlab-release.yaml
```

## Parameters

- **TAG_NAME**: A git tag name that will be created with this release(_e.g:_`v1.0.0`).
- **NAME**: The Name of the release (_e.g:_`First release`).
- **DESCRIPTION**: A short description of the release (_default:_`""`).
- **RELEASE_REF**: It can be a commit SHA, another tag name, or a branch name (_default:_`master`).
- **PROJECT_ID**: The Gitlab id of the project, can be found on the repository page of the gitlab (_e.g:_`18587362`)
- **UPLOAD_ASSET_NAME**: The name of the asset that needs to be uploaded (_default:_`""`).
- **UPLOAD_ASSET_URL**: The uplaod URL for the hosted asset (_default:_`""`).
- **GITLAB_TOKEN_SECRET**: The name of the `secret` holding the gitlab-token (_default:_`gitlab-token`).
- **GITLAB_TOKEN_SECRET_KEY**: The name of the `secret key` holding the gitlab-token (_default:_`GITLAB_TOKEN`).


## Secrets
* `Secret` to provide personal `access token` of the Gitlab.

Check [this](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html) to get personal access token for `Gitlab`.

## Usage

This task expects a secret named gitlab-token to exists, with a Gitlab personal access token in `GITLAB_TOKEN` with enough privileges to create a release.

At present, `Gitlab` doesn't provide the functionality to upload any file to the release directly, however file that is hosted on any platform (i.e `aws s3` or `gitlab`) can be uploaded with the release by providing the hosted file `URL path` as the param to the task.

To make a release put all the required params in the Taskrun, add required secrets and release will be done.

`Secrets` can be created as follows:
```
apiVersion: v1
kind: Secret
metadata:
  name: gitlab-token
type: Opaque
stringData:
  GITLAB_TOKEN: $(personal-gitlab-token)
```

This [example](../gitlab/create-gitlab-release/example/run.yaml) can be referred to create Taskrun for Gitlab release. 