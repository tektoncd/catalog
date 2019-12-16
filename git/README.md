# Git tasks

These Tasks are Git tasks to clone a repository in the workspace to be
used by other tasks in a Pipeline.

This is a `Task` that does the job of the `GitResource`
`PipelineResource`. This is linked to
[tektoncd/pipeline#1369](https://github.com/tektoncd/pipeline/issues/1369).

## `fetch-git`

### Inputs

#### Parameters

* **url**: git url to clone
* **revision**: git revision to checkout (branch, tag, sha, ref…) (_default:_ master)
* **workingDirectory**: working directory to clone (_default:_ .)
* **submodules**: init and fetch recursively submodules (_default:_ true)

## Usage

### `fetch-git`

This pipeline uses the Task to clone the
[`tektoncd/pipeline`](https://github.com/tektoncd/pipeline) repository
and display the README in the next step

```yaml
apiVersion: tekton.dev/v1alpha1
kind: Task
metadata:
  name: cat-readme
spec:
  steps:
  - name: clone
    image: ubuntu
    workingdir: /workspace/src/
    command:
    - /bin/bash
	- -c
    args:
    - "cat README"
    volumeMounts:
    - name: source
      mountPath: /workspace/src
---
apiVersion: tekton.dev/v1alpha1
kind: Pipeline
metadata:
  name: cat-pipeline-readme
spec:
  tasks:
  - name: fetch-repository
    taskRef:
      name: fetch-git
    params:
    - name: url
      value: github.com/tektoncd/pipeline
  - name: cat-readme
    taskRef:
      name: echo-readme
```

This pipeline can be used as the following `PipelineRun` does.

```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: source
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
  podTemplate:
    volumes:
    - name: source
      persistentVolumeClaim:
        claimName: source
```
