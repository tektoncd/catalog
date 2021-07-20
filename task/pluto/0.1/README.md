# Pluto

[Pluto](https://github.com/FairwindsOps/pluto) is a tool by Fairwinds which help users to find deprecated and removed Kubernetes apiVersions.

## Installation
```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/pluto/0.1/pluto.yaml
```

## Pre-requisite
Install git-clone task from catalog
```
https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-clone/0.3/git-clone.yaml
```

## Workspaces
* **source** : A Workspace containing your source directory.

## Parameters
* **manifest** : path to manifest file or directory. (default: `.`)
* **output_format** : format in which report will be generated. (normal|wide|custom|json|yaml|markdown) (default: `normal`)
* **args** : args. (default: `[]`)

## Usage

```yaml
---
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: pluto-pipeline
spec:
  workspaces:
  - name: workspace
  tasks:
  - name: clone-git-repo
    workspaces:
    - name: output
      workspace: workspace
    taskRef:
      name: git-clone
    params:
      - name: url
        value: https://github.com/urvashigupta7/Go-Server
      - name: deleteExisting
        value: "true"
  - name: pluto
    runAfter:
    - clone-git-repo
    taskRef:
      name: pluto
    workspaces:
      - name: source
        workspace: workspace
    params:
      - name: manifest
        value: k8
      - name: output_format
        value: json
---
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: pluto-pipelinerun
spec:
  pipelineRef:
    name: pluto-pipeline
  workspaces:
  - name: workspace
    persistentvolumeclaim:
      claimName: pvc