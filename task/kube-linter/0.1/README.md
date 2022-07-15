# Kube-Linter

The [KubeLinter](https://github.com/stackrox/kube-linter) tool by StackRox is an open-source command-line interface to identify misconfigurations in Kubernetes objects. KubeLinter offers the ability to integrate checks on Kubernetes YAML files and Helm charts before deployment into a Kubernetes cluster. It has 31 standard [built-in](https://docs.kubelinter.io/#/generated/checks) checks and the room to configure your own by providing [templates](https://docs.kubelinter.io/#/generated/templates) which can be configured to create new checks. It provides immediate feedback about misconfigurations and Kubernetes security violations.

## Install the Task
```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/kube-linter/0.1/raw
```

## Pre-requisite
Install git-clone task from catalog
```
https://api.hub.tekton.dev/v1/resource/tekton/task/git-clone/0.3/raw
```

## Workspaces
* **source** : A Workspace containing your source directory.

## Parameters
* **config_file_url** : url from where the config file would be fetched.
* **config_file_path** : path to config file(written in YAML) for custom checks.
* **manifest** : path to manifest files or manifest directory to be checked. (default: `.`)
* **includelist** : checks to be included.
* **excludelist** : checks to be excluded.
* **default_option** : provides two options (adding all built-in checks or disabling all default checks): add-all-built-in and/do-not-auto-add-defaults.
* **output_format** : format in which report will be generated. (json|sarif|plain) (default: `json`)
* **args** : args. (default: `[]`)

> _Note_ :  If you want to create your own custom checks using templates and built-in checks, you can create a config file containing all the checks. An example config file can be seen [here](https://raw.githubusercontent.com/tektoncd/catalog/main/task/kube-linter/0.1/samples/config_sample2.yaml). Otherwise, you can provide a string with comma-separated built-in checks to be included or excluded in `includelist` and `exludelist` param.

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

```yaml
---
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: kubelinter-pipeline
spec:
  params:
    - name: repository
      type: string
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
        value: $(params.repository)
      - name: deleteExisting
        value: "true"
  - name: kube-linter
    runAfter:
    - clone-git-repo
    taskRef:
      name: kube-linter
    workspaces:
      - name: source
        workspace: workspace
    params:
      - name: manifest
        value: k8
      - name: default_option
        value: do-not-auto-add-defaults
      - name: includelist
        value: "no-extensions-v1beta,default-service-account,no-readiness-probe"
---
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: kubelinter-pipelinerun
spec:
  pipelineRef:
    name: kubelinter-pipeline
  params:
  - name: repository
    value: https://github.com/urvashigupta7/Go-Server
  workspaces:
  - name: workspace
    persistentvolumeclaim:
      claimName: pvc

```