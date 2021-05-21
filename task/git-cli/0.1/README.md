# Git Task

This `Task` is Git task to work with repositories used by other tasks
in your Pipeline.

## `git-cli`

This [task](../0.1/git-cli.yaml) can be used to perform `git operations`.
All git commands can be found [here](https://git-scm.com/docs).

Command that needs to be run can be passed as a script to the task.

### Workspaces

* **source**: A workspace that contains the fetched git repository.
* **input**: A workspace that contains file that needs to be added to git.

### Parameters

* **BASE_IMAGE**: The base image for the task.
(_default_: `alpine/git:latest`)
* **GIT_USER_NAME**: Git user name for performing git operation.
* **GIT_USER_EMAIL**:  Git user email for performing git operation.
* **GIT_SCRIPT**: The git script to run. (_required_)

### Results

* **commit**: The precise commit SHA after git operation is performed.

### Usage

This task needs authentication to git in order to push after the git operation.
This can be done via `secrets` and `service account`.
Refer [this](./samples/secret.yaml)
example to create secret and service account for the git authentication.

After creating the task, you should now be able to execute `git` commands by
specifying the command you would like to run as the `GIT_SCRIPT` param.

`Example`:

```yaml
  params:
    - name: GIT_SCRIPT
      value: |
        git init
        git remote add origin https://github.com/kelseyhightower/nocode
        git pull origin master
```
[Git Pipeline](../0.1/samples/pipeline.yaml) can be referred to use
this task in the pipeline.

**NOTE**

* If `two factor authentication` is enabled in your git account, then
`access-token` for the respective git platform must be provided
in the `password` field while adding secrets.