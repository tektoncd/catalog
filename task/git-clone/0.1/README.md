# Git Task

This `Task` is Git task to work with repositories used by other tasks
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
* **userHome**: The user's home directory. Set this explicitly if you are running the image as a non-root user. (_default_: "/tekton/home")

### Results

* **commit**: The precise commit SHA that was fetched by this Task

## Usage

### `git-clone`

The following pipelines demonstrate usage of the git-clone Task:

- [Cloning a branch](../0.1/samples/git-clone-checking-out-a-branch.yaml)
- [Checking out a specific git commit](../0.1/samples/git-clone-checking-out-a-commit.yaml)
- [Checking out a git tag and using the "commit" Task Result](../0.1/samples/using-git-clone-result.yaml)
