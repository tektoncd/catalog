# Pluto Task
[Pluto](https://pluto.docs.fairwinds.com/) is a utility to help users find deprecated Kubernetes apiVersions 
in their code repositories and their helm releases.

## Install the Task
Install `pluto` task:

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/pluto/0.1/raw
```

## Parameters
* **ARGS:** args to execute which are appended to `pluto` e.g. `detect-files -d pkg/finder/testdata` (_default_: `help`)

## Workspaces
- **source** : A workspace that contains the helm chart/resources that will be processed.

## Platforms
The Task can be run on `linux/amd64` platform.

## Usage
```yaml
---
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: pluto-pipeline
spec:
  workspaces:
    - name: shared-workspace
  params:
    - name: git-url
      type: string
      description: url of the git repo for the code of deployment
      default: https://github.com/garethahealy/pluto-blog.git
    - name: git-revision
      type: string
      description: revision to be used from repo of the code for deployment
      default: "main"
    - name: pluto-args
      type: array
      description: pluto commands to run
      default:
        - detect-files
        - -d
        - charts/v1beta1/templates
  tasks:
    - name: fetch-repository
      taskRef:
        name: git-clone
        kind: ClusterTask
      workspaces:
        - name: output
          workspace: shared-workspace
      params:
        - name: url
          value: $(params.git-url)
        - name: subdirectory
          value: ""
        - name: deleteExisting
          value: "true"
        - name: revision
          value: $(params.git-revision)
    - name: pluto
      taskRef:
        name: pluto
      runAfter:
        - fetch-repository
      workspaces:
        - name: source
          workspace: shared-workspace
      params:
        - name: ARGS
          value:
          - $(params.pluto-args)
---
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: pluto-pipeline-run
spec:
  pipelineRef:
    name: pluto-pipeline
  workspaces:
    - name: shared-workspace
      volumeClaimTemplate:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 500Mi
```
