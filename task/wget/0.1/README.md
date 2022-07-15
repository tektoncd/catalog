
# `wget`

This task uses wget to download files from the internet to a workspace  .

## Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/wget/0.1/raw
```

## Parameters

* **options**: The arguments to pass to `wget` CLI.  _default_: `[""]`
* **diroptions**: The directory path we want to save file to.  _default_: `[""]`
* **url**: The url we want to download file from.  _default_: `""`
* **filename**: The filename we want to change our file to.  _default_: `""`
* ****: The wget docker image to be used. Defaults to `mwendler/wget`

## Platforms

The Task can be run on `linux/amd64`, `linux/s390x`, and `linux/ppc64le` platforms.

## Usage

### Running the Task

#### Download file to the workspace

You can invoke `wget url -P workspace` to check if file is downloaded to workspace:

Create a file, `wget-run.yaml`:

```
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: wget-run
spec:
  params:
    - name: url
      value: "www.google.com"
    - name: diroptions
      value:
        - "-P"
  taskRef:
    name: wget
  workspaces:
    - name: wget-workspace
      emptyDir: {}
```

Run it with `kubectl apply -f wget-run.yaml`

When this runs, it will print logs indicating connecting to the website indicated in url, http request sent and saving a `index.html` to the workspace directory
