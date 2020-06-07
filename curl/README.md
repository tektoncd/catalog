
# `curl`

This task performs curl operation to transfer data from internet .

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/curl/curl.yaml
```

## Parameters

* **options**: The arguments to pass to `curl` CLI.  _default_: `[""]`
* **url**: The url we want to download file from, required field.
* **curl-image**: The curl docker image to be used. Defaults to `curlimages/curl`.
## Usage

### Running the Task

#### Viewing request headers and connection details

You can invoke `curl -i url` to get request header from specified url:

Create a file, `curl-header-run.yaml`:

```
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: curl-header-run
spec:
  params:
    - name: url
      value: "www.google.com"
    - name: options
      value:
       - "-i"
  taskRef:
    name: curl
```

Run it with `kubectl apply -f curl-header-run.yaml`

When this runs, it will print logs containing only headers of the response

#### View full response from request to specified url
You can invoke `curl url` to get a full response from specified url:

Create a file, `curl-reponse-run.yaml`:
```
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: curl-response-run
spec:
  params:
    - name: url
      value: "www.google.com"
  taskRef:
    name: curl
```
Run it with `kubectl apply -f curl-response-run.yaml`

When this runs, it will print logs containing full response fields of the request

#### Use a different version of curl image
You can invoke `curl url` to get a full response from specified url while specifying a different image in taskrun:

Create a file, `curl-diffimage-run.yaml`:
```
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: curl-diffimage-run
spec:
  params:
    - name: url
      value: "www.google.com"
    - name: curl-image
      value: "appropriate/curl"
  taskRef:
    name: curl
```
Run it with `kubectl apply -f curl-diffimage-run.yaml`

When this runs, it will print logs containing full response fields of the request as in the last example, but now uses a different version of image


