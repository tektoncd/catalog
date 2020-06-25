# Git Tasks

These `Tasks` are Git tasks to work with repositories used by other tasks
in your Pipeline.

- [Git CLI](#git-cli)
- [Git Clone](#git-clone)
- [Git Batch Merge](#git-batch-merge)
- [Git Rebase](#git-rebase)

## `git-cli`

This [task](../git/git-cli.yaml) can be used to perform `git operations`.
All git commands can be found [here](https://git-scm.com/docs).

Command that needs to be run can be passed as a script to the task.

### Workspaces

* **source**: A workspace that contains the fetched git repository.
* **input**: A workspace that contains file that needs to be added to git.

### Parameters

* **BASE_MAGE**: The base image for the task.
(_default_: `alpine/git:latest`)
* **GIT_USER_NAME**: Git user name for performing git operation.
* **GIT_USER_EMAIL**:  Git user email for performing git operation.
* **GIT_SCRIPT**: The git script to run. (_required_)

### Results

* **commit**: The precise commit SHA after git operation is performed.

### Usage

This task needs authentication to git in order to push after the git operation.
This can be done via `secrets` and `service account`. 
Refer [this](../git/examples/git-cli) 
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
[Git Pipeline](../git/examples/git-cli/pipeline.yaml) can be referred to use
this task in the pipeline.

**NOTE**

* If `two factor authentication` is enabled in your git account, then
`access-token` for the respective git platform must be provided
in the `password` field while adding secrets.


## `git-clone`

**Please Note: this Task is only compatible with Tekton Pipelines versions 0.11-rc1 and greater!**

This `Task` has two required inputs:

1. The URL of a git repo to clone provided with the `url` param.
2. A Workspace called `output`.

The `git-clone` `Task` will clone a repo from the provided `url` into the
`output` Workspace. By default the repo will be cloned into the root of
your Workspace. You can clone into a subdirectory by setting this `Task`'s
`subdirectory` param.

This `Task` does the job of the legacy `GitResource` `PipelineResource` and
is intended as its replacement. This is part of our plan to [offer replacement
`Tasks` for Pipeline Resources](https://github.com/tektoncd/catalog/issues/95)
as well as
[document those replacements](https://github.com/tektoncd/pipeline/issues/1369).

### Workspaces

* **output**: A workspace for this Task to fetch the git repository in to.

### Parameters

* **url**: git url to clone (_required_)
* **revision**: git revision to checkout (branch, tag, sha, ref…) (_default:_ master)
* **refspec**: git refspec to fetch before checking out revision (_default_:refs/heads/master:refs/heads/master)
* **submodules**: defines if the resource should initialize and fetch the submodules (_default_: true)
* **depth**: performs a shallow clone where only the most recent commit(s) will be fetched (_default_: 1)
* **sslVerify**: defines if http.sslVerify should be set to true or false in the global git config (_default_: true)
* **subdirectory**: subdirectory inside the "output" workspace to clone the git repo into (_default:_ "")
* **deleteExisting**: clean out the contents of the repo's destination directory if it already exists before cloning the repo there (_default_: false)
* **httpProxy**: git HTTP proxy server for non-SSL requests
* **httpsProxy**: git HTTPS proxy server for SSL requests
* **noProxy**: git no proxy - opt out of proxying HTTP/HTTPS requests

### Results

* **commit**: The precise commit SHA that was fetched by this Task

## Usage

### `git-clone`

The following pipelines demonstrate usage of the git-clone Task:

- [Cloning a branch](./examples/git-clone-checking-out-a-branch.yaml)
- [Checking out a specific git commit](./examples/git-clone-checking-out-a-commit.yaml)
- [Checking out a git tag and using the "commit" Task Result](./examples/using-git-clone-task-result.yaml)

## `git-batch-merge`

This task takes a set of refspecs, fetches them and performs git operations
(cherry-pick or merge) to apply them in order on the given base revision (default master).
The resulting commit SHA will not match across taskruns, but the git tree SHA should
match. This can be useful for batch testing changes, for example, when you want to
batch up your PRs into a single merge by taking the HEAD of the branch you want to merge
to, and adding all the PRs to it. This concept is used in tools such as [Tide][tide] to
batch test PR's, and [Zuul CI Gating][zuul-ci], to perform speculative execution of
PR's/change requests individually

This `Task` has four required inputs:

1. The URL of a git repo to clone provided with the `url` param.
1. A space separated string of refs `BatchedRefs` to fetch and batch over the given `revision`
1. Merge `mode` to use while batching (merge, merge-resolve, merge-squash, cherry-pick)
1. A Workspace called `output`.

There are 4 additional parameters in addition to the ones mentioned above for the git-clone task:
* **batchedRefs**: space separated git [refnames][git-ref] to fetch and batch on top of revision using the given mode
    (must be a valid refs, no commit SHA's).
* **mode**: Batch mode to select (_default_: merge) <br>
  &nbsp;&nbsp;`merge`: corresponds to git merge -s recursive. This is the default mode used by github <br>
  &nbsp;&nbsp;`cherry-pick`: corresponds to git cherry-pick <br>
  See [git-merge][git-merge] and [git-cherry-pick][git-cherry-pick]
* **gitUserName**: git user name to use for creating the batched commit (First Last)
    (_default_: GitBatch Task). See [git-user-config][git-user-config]
* **gitUserEmail**: git user email to use for creating the batched commit (First.Last@domain.com)
  (_default_: GitBatch.Task@tekton.dev). See [git-user-config][git-user-config]

### Results

* **commit**: The precise commit SHA that was fetched by this Task
* **tree**: The [git tree][git-tree] object SHA that was created after batch merging the refs on HEAD.

### Usage

[git-ref]: https://git-scm.com/book/en/v2/Git-Internals-Git-References
[git-merge]: https://git-scm.com/docs/git-merge
[git-cherry-pick]: https://git-scm.com/docs/git-cherry-pick
[git-user-config]: https://git-scm.com/docs/git-config#Documentation/git-config.txt-username
[git-tree]: https://git-scm.com/book/en/v2/Git-Internals-Git-Objects
[tide]: https://github.com/kubernetes/test-infra/blob/master/prow/cmd/tide/README.md
[zuul-ci]: https://zuul-ci.org/docs/zuul/discussion/gating.html

## `git-rebase`

This [task](../git/git-rebase.yaml) will `rebase` the branch based
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

### Usage

This task needs authentication to git in order to push after the rebase.
This can be done via `secrets` and `service account`. Refer [this](../git/git-rebase-example) 
example to create secret and service account for the git authentication.

[Git Rebase](../git/git-rebase-example) pipeline has two tasks, one to clone a 
git repository in the provided workspace and other to perform rebase operation.
Here, [git-clone](../git/git-clone.yaml) task is used to clone the repository.

A workspace called "shared-workspace" is passed first to the `git-clone`
Task for the code to be checked out on and then to the `git-rebase` Task
to perform the rebase operation.

Remote name, Remote URL and Branch name needs to provided in the input 
to set the remote in order to perfrom push and pull operations.

[Git Rebase](../git/git-rebase-example/run.yaml) pipeline can be referred to 
create a `pipeline` and `pipelinerun`.

**NOTE**

* If `two factor authentication` is enabled in your git account, then
`access-token` for the respective git platform must be provided
in the `password` field while adding secrets.

* In the params for `git-clone` task, make sure that param value 
for `depth` must be greater than param value for `SQUASH_COUNT` in `git-rebase` task.

* If there are chances for `merge conflicts`, then that needs to resolved before 
doing rebase through this task as task will fail, if any merge conflict is found.  