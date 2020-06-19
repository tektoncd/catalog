# Create Github Release

It is typical to create a Github tag at the moment of release to introduce a checkpoint in your source code history,
but in most cases users will need compiled objects or other assets output, not just the raw source code.

Github Releases are a way to track deliverables in your project. Consider them a snapshot in time of the source,
build output, artifacts, and other metadata associated with a released version of your code.

This `task` can be used to make a github release.

Task can also be used to upload multiple `assets` including `binaries` of the released version and the release notes, with the release.

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/github/create-github-release/create-github-release.yaml
```

## Parameters

- **TAG**: A git tag name that will be created with this release (_e.g:_`v1.0.0`).
- **REVISION**: A Git revision to create a release from (branch, tag, sha, ref…) (_default:_`master`).
- **RELEASE_FILE_NAME**: Name of the file that has to be uploaded as release notes (_default:_`release.md`).
- **GITHUB_TOKEN_SECRET**: The name of the `secret` holding the github-token (_default:_`github-token`).
- **GITHUB_TOKEN_SECRET_KEY**: The name of the `secret key` holding the github-token (_default:_`GITHUB_TOKEN`).


## Workspace

- **input**: To mount `asset` which has to be uploaded with the release.
- **source**: Contains Github `repository `on which release has to be made.
- **release-notes**: To mount file that has to provided as `release notes` in the release.


## Secrets

* `Secret` to provide Github `access token` to authenticate to the Github.

Check [this](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line) to get personal access token for `Github`.


## Usage


This task expects a secret named github-token to exists, with a GitHub token in `GITHUB_TOKEN` with enough privileges to create a release.

This task can upload multiple assets with the release on the `github`, in order to do that any volume (supported in workspace) 
can be mounted in the workspace named `input` containing all the assets that needs to be uploaded.

Release Notes can also be uploaded with the release by mounting the the release notes file in the workspace named `release-notes`. 
Name of the release notes file should also be provided in the params, default is `release.md`.

Release can be created at a particular branch, tag or commit sha, to achieve that, 
required branch, tag or commit sha can be added in the param `commitish`.

Github repository on which release has to be performed must be available in the workspace named `source`. This can be done using 
[git-clone](https://github.com/tektoncd/catalog/blob/master/git/git-clone.yaml) task as shown [here](../github/create-github-release/example/run.yaml).


To make a release put all the required params, add required secrets and release will be done.

`Secrets` can be created as follows:
```
apiVersion: v1
kind: Secret
metadata:
  name: github-token
type: Opaque
stringData:
  GITHUB_TOKEN: $(personal_access_token)
```

[This](../github/create-github-release/example) example uses ConfigMap for mounting asset file to the workspace, ConfigMap can be created as follows:

```
kubectl create configmap upload-asset --from-file=file1.txt --from-file=file2.txt 
``` 

### Note 


- If case asset is not to be uploaded with the release, then `emptyDir` needs to be mounted in the `workspace` as shown below:

    ```
    workspaces:
      - name: input
        emptyDir: {}
        
    ```
- Task uses image from `quay.io/diagrawa/github-hub` which is based on [this](https://github.com/Divyansh42/github-hub) Dockerfile.
