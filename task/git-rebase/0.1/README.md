# Git Task

This `Task` is Git task to work with repositories used by other tasks
in your Pipeline.

## `git-rebase`

This [task](../0.1/git-rebase.yaml) will `rebase` the branch based
on the user input. Before rebase, if `squashing` of the commits is required,
then it can be done by providing the `squash count` i.e number of commits to squash.

### Workspaces

* **source**: A workspace that contains the fetched git repository.

### Parameters

* **SQUASH_COUNT**: Number of commits to squash in the branch.
(_only required if squashing needs to be performed_).
* **COMMIT_MSG**: Commit message to add in commit after the
 squashing is done (_only required if squashing needs to be performed_).
* **GIT_USER_NAME**: Git user name to use for rebase (_required_).
* **GIT_USER_EMAIL**: Git user email to use for rebase (_required_).
* **PULL_REMOTE_NAME**: Git remote name from which we have to pull
and rebase.(_default_: `origin`).
* **PULL_REMOTE_URL**: Git remote URL from which we have to
pull and rebase (_required to set remote_).
* **PULL_BRANCH_NAME**: Git branch name from which we have to
pull and rebase (_required_).
* **PUSH_REMOTE_NAME**: Git remote name to push after rebase(_default_: `origin`).
* **PUSH_REMOTE_URL**:  Git remote URL to push after rebase(_required_).
* **PUSH_BRANCH_NAME**: Git branch name to push after rebase (_required_).

### Results

* **commit**: The precise commit SHA after the rebase.

### Platforms

The Task can be run on `linux/amd64`, `linux/s390x`, `linux/arm64`, and `linux/ppc64le` platforms.

## Platforms

The Task can be run on `linux/amd64` platform.

### Usage

This task needs authentication to git in order to push after the rebase.
This can be done via `secrets` and `service account`. Refer [this](../0.1/samples/git-rebase)
example to create secret and service account for the git authentication.

[Git Rebase](../0.1/samples/run.yaml) pipeline has two tasks, one to clone a
git repository in the provided workspace and other to perform rebase operation.
Here, [git-clone](../../git-clone/0.1/git-clone.yaml) task is used to clone the repository.

A workspace called "shared-workspace" is passed first to the `git-clone`
Task for the code to be checked out on and then to the `git-rebase` Task
to perform the rebase operation.

Remote name, Remote URL and Branch name needs to provided in the input
to set the remote in order to perfrom push and pull operations.

[Git Rebase](../0.1/samples/run.yaml) pipeline can be referred to
create a `pipeline` and `pipelinerun`.

**NOTE**

* If `two factor authentication` is enabled in your git account, then
`access-token` for the respective git platform must be provided
in the `password` field while adding secrets.

* In the params for `git-clone` task, make sure that param value
for `depth` must be greater than param value for `SQUASH_COUNT` in `git-rebase` task.

* If there are chances for `merge conflicts`, then that needs to resolved before
doing rebase through this task as task will fail, if any merge conflict is found.