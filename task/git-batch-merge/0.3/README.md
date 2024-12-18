# Git Task

This `Task` is Git task to work with repositories used by other tasks
in your Pipeline.

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

## Platforms

The Task can be run on `linux/amd64`, `linux/s390x`, `linux/arm64`, and `linux/ppc64le` platforms.

### Usage

[git-ref](https://git-scm.com/book/en/v2/Git-Internals-Git-References)
[git-merge](https://git-scm.com/docs/git-merge)
[git-cherry-pick](https://git-scm.com/docs/git-cherry-pick)
[git-user-config](https://git-scm.com/docs/git-config#Documentation/git-config.txt-username)
[git-tree](https://git-scm.com/book/en/v2/Git-Internals-Git-Objects)
[tide](https://github.com/kubernetes/test-infra/blob/master/prow/cmd/tide/README.md)
[zuul-ci](https://zuul-ci.org/docs/zuul/discussion/gating.html)
