# Git Tasks

These `Tasks` are Git tasks to work with repositories used by other tasks
in your Pipeline.

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
