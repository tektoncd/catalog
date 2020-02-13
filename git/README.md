# Git Tasks

These Tasks are Git tasks to clone a repository in the workspace to be
used by other tasks in a Pipeline.

This is a `Task` that does the job of the `GitResource`
`PipelineResource`. This is linked to
[tektoncd/pipeline#1369](https://github.com/tektoncd/pipeline/issues/1369).

## `git-clone`

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

### Results

* **commit**: The precise commit SHA that was fetched by this Task

### Notes On Usage

The `git-init` binary that this task uses to perform a clone will error out if the directory you're
cloning into is already a git repo. In particular this can become a problem when you reuse a directory on a
Persistent Volume Claim as git-clone's "output" workspace multiple times. One simple fix for this is to add a
Task before git-clone that "cleans" the workspace first by running `rm -rf` if the directory already
exists in the workspace. This may become a configurable parameter of this task at some point in the future.

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
