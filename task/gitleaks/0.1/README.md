# Gitleaks

Gitleaks is a SAST tool for detecting hardcoded secrets like passwords, api keys, and tokens in git repos. It is an easy-to-use, all-in-one solution for finding secrets, past or present, in your code.
This task makes it possible to use [gitleaks](https://github.com/zricethezav/gitleaks) within your Tekton pipelines.

## Installation
```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/gitleaks/0.1/raw
```

## Pre-requisite
Install git-clone task from catalog
```
https://api.hub.tekton.dev/v1/resource/tekton/task/git-clone/0.3/raw
```


## Workspaces
* **source** : A Workspace containing your source directory.

## Parameters
* **repo_path** : path to the repo to be scanned.
* **config_file_url** : url from where the config file would be fetched.
* **config_file_path** : path to config file.
* **output_format** : format in which report will be generated. (json|csv|sarif) (default: `json`)
* **report_output_path** : path of file to save analysis report.
* **args** : args. (default: `[]`)

> _Note_ :  Gitleaks provides some default rulesets for detecting secrets which you can find [here](https://github.com/zricethezav/gitleaks/blob/master/config/default.go). However, user is free to create rulesets as per his requirement by defining them inside (.toml) format file. To know how to write these config file, you can visit this [link](https://github.com/zricethezav/gitleaks#rules-summary). Also, if you want to checkout an example config file, please head over to this [link](https://raw.githubusercontent.com/urvashigupta7/secret_detection/master/gitleaks.toml). The config file can exist in the repository to be scanned or some other repository, if the config file is present in some other repository, you would need to provide url of **config_file_url** and the **config_file_path** where config file would be saved after fetching else you need to provide **config_file_path** only.

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

```yaml
---
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: gitleaks-pipeline
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
        value: https://github.com/urvashigupta7/contest-arena
      - name: deleteExisting
        value: "true"
      - name: subdirectory
        value: contest-arena
  - name: secret-detection
    runAfter:
    - clone-git-repo
    taskRef:
      name : gitleaks
    workspaces:
      - name: source
        workspace: workspace
    params:
    - name: repo_path
      value: contest-arena
    - name: config_file_url
      value: https://raw.githubusercontent.com/tektoncd/catalog/main/task/gitleaks/0.1/samples/gitleaks.toml
    - name: config_file_path
      value: gitleaks.toml
    - name: output_format
      value: json
    - name: report_output_path
      value: report.json
    - name: args
      value: ["--verbose","--no-git"]
---
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: gitleaks-pipelinerun
spec:
  pipelineRef:
    name: gitleaks-pipeline
  workspaces:
  - name: workspace
    persistentvolumeclaim:
      claimName: gitleaks-pvc

```
> _Note_ : Gitleaks can consider repository to be scanned as plain directory or as git repositories. If you want it to be treated as plain directory, you will need to pass **--no-git** option as arg in gitleaks task. git-clone task by default clone of depth equals to 1, but if you want to treat the repository as git repo and want to scan more than 1 commit, pass **depth** param to the git-clone task
