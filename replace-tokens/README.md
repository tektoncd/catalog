# Replace Tokens

This task can be used to replace tokens in a file. The supported file types are `YAML` and `JSON`. 
The following task can be explained by taking an example of a `JSON` file :-

config.json
```
{
  "image": "$(image)",
  "server": "$(server)",
  "dbname": "$(dbname)",
  "password": "$(dbpass)"
}
```
token.json
```
{
  "image": "ubuntu",
  "server": "localhost:3306",
  "dbname": "tektondb",
  "dbpass": "tektonpass"
}
```
After replacing the config.json becomes:-
```
{
  "image": "ubuntu",
  "server": "localhost:3306",
  "dbname": "tektondb",
  "password": "tektonpass"
}
```
The above same can be done for the `YAML` file also.

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/replace-tokens/replace-tokens.yaml
```

## Parameters

- **inputFilePath**: The file path whose value needs to be replaced.

## Resources

* `Persistent Volume claim` to store the json file, in which token is replaced.
* `ConfigMap` contains file `tokens.json` or `token.yaml` which stores the tokens and corresponding value that need to be replaced.
* `Workspace` to mount file containing tokens and its corresponding value, and PVC to store the replaced file.
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: replace-tokens-source-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
```

## Usage

This task will use the input param `inputFilePath`, this is provided by the [git clone](https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/git/git-clone.yaml) task, which clones the target repository containing the json or yaml file to be replaced.

ConfigMap is created from the `tokens.json` or `tokens.yaml` file, which contains tokens and its corresponding value that needs to be replaced. ConfigMap is mounted in the workspace, which is used in the task to access the `tokens.json` or `tokens.yaml` file.
`ConfigMap` should be created using this file. Following `command` can be used to create congfigmap from the `file`.
```
kubectl create configmap tokens-configmap --from-file=tokens.json
```
or
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: tokens-configmap
data:
  tokens.json: |
    { "hello":"bye", "fortnite":"league of legends", "github":"tekton" }
```

Create the Pipeline and PipelineRun

```
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: replace-tokens-pipeline
spec:
  workspaces:
    - name: shared-workspace
    - name: json-workspace
  tasks:
    - name: fetch-repository
      taskRef:
        name: git-clone
      workspaces:
        - name: output
          workspace: shared-workspace
      params:
        - name: url
          value: https://github.com/vinamra28/replace-tokens-plugin.git
        - name: subdirectory
          value: ""
        - name: deleteExisting
          value: "true"
    - name: replace-tokens
      taskRef:
        name: replace-tokens
      params:
        - name: inputFilePath
          value: "./sample1.json"
      runAfter:
        - fetch-repository
      workspaces:
        - name: source
          workspace: shared-workspace
        - name: token
          workspace: json-workspace
---
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: replace-tokens-pipeline-run
spec:
  pipelineRef:
    name: replace-tokens-pipeline
  workspaces:
    - name: shared-workspace
      persistentvolumeclaim:
        claimName: replace-tokens-source-pvc
    - name: json-workspace
      configmap: 
        name: tokens-configmap
```