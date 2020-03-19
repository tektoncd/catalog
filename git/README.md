# Git Tasks

These `Tasks` are Git tasks to work with repositories used by other tasks
in your Pipeline.

## `git-clone`

**Please Note: this Task is only compatible with Tekton Pipelines versions 0.11-rc1 and greater!**

This `Task` has two required inputs:

1. The URL of a git repo to clone provided with the `url` param.
2. A Workspace called `output`.

The `git-clone` `Task` will clone a repo from the provided `url` into the
`output` Workspace. By default the repo will be cloned into a subdirectory
called "src" in your Workspace. You can clone into an alternative subdirectory
by setting this `Task`'s `subdirectory` param.

This `Task` does the job of the legacy `GitResource` `PipelineResource` and
is intended as its replacement. This is part of our plan to [offer replacement
`Tasks` for Pipeline Resources](https://github.com/tektoncd/catalog/issues/95)
as well as
[document those replacements](https://github.com/tektoncd/pipeline/issues/1369).

### Workspaces

* **output**: A workspace for this Task to fetch the git repository in to.

### Inputs

#### Parameters

* **url**: git url to clone (_required_)
* **revision**: git revision to checkout (branch, tag, sha, ref…) (_default:_ master)
* **submodules**: defines if the resource should initialize and fetch the submodules (_default_: true)
* **depth**: performs a shallow clone where only the most recent commit(s) will be fetched (_default_: 1)
* **sslVerify**: defines if http.sslVerify should be set to true or false in the global git config (_default_: true)
* **subdirectory**: subdirectory inside the "output" workspace to clone the git repo into (_default:_ src)
* **deleteExisting**: clean out the contents of the repo's destination directory if it already exists before cloning the repo there (_default_: false)
* **httpProxy**: git HTTP proxy server for non-SSL requests
* **httpsProxy**: git HTTPS proxy server for SSL requests
* **noProxy**: git no proxy - opt out of proxying HTTP/HTTPS requests

### Results

* **commit**: The precise commit SHA that was fetched by this Task

## Usage

### `git-clone`

This pipeline uses the git-clone Task to check out the
[`tektoncd/pipeline`](https://github.com/tektoncd/pipeline) repository
and then display that repo's README.md.

A workspace called "shared-workspace" is passed first to the `git-clone`
Task for the code to be checked out on and then to the `cat-readme` Task
to print the README.md file from.

After the Pipeline has run you'll be able to see a
[Task Result](https://github.com/tektoncd/pipeline/blob/master/docs/taskruns.md#results)
named `commit` in the PipelineRun's Status with the commit SHA that was
fetched by the `git-clone` Task.

```yaml
apiVersion: tekton.dev/v1alpha1
kind: Task
metadata:
  name: cat-readme
spec:
  workspaces:
  - name: source
    mountPath: /source
  inputs:
    params:
    - name: subdirectory
      description: Subdirectory inside "source" workspace that contains the README.md.
      default: "."
  steps:
  - name: cat-readme
    image: ubuntu
    script: cat "$(workspaces.source.path)/$(inputs.params.subdirectory)/README.md"
---
apiVersion: tekton.dev/v1alpha1
kind: Pipeline
metadata:
  name: cat-pipeline-readme
spec:
  workspaces:
  - name: shared-workspace
    # description: The git repo will be cloned into this workspace and the readme will be read from it.
  tasks:
  - name: fetch-repository
    taskRef:
      name: git-clone
    workspaces:
    - name: output
      workspace: shared-workspace
    params:
    - name: url
      value: https://github.com/tektoncd/pipeline.git
    - name: subdirectory
      value: pipeline-checkout
  - name: print-readme
    taskRef:
      name: cat-readme
    runAfter:
    - fetch-repository # required to ensure clone occurs before reading
    workspaces:
    - name: source
      workspace: shared-workspace
    params:
    - name: subdirectory
      value: pipeline-checkout
```

This pipeline can be used as the following `PipelineRun` does.

```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: workspace-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
---
apiVersion: tekton.dev/v1alpha1
kind: PipelineRun
metadata:
  name: cat-pipeline-readme-run
spec:
  pipelineRef:
    name: cat-pipeline-readme
  workspaces:
  - name: shared-workspace
    persistentVolumeClaim:
      claimName: workspace-pvc
```
