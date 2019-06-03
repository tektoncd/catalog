# Curl

This Task runs curl agains provided URL with provided ARGS.

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/curl/curl.yaml
```

## Inputs

### Parameters

* **URL:**: URL to be curl'ed. (_default:_ empty)
* **ARGS**: Arguments for curl. (_default:_ empty)

## Usage

### CHANGE THIS SECTION
This TaskRun runs the Task to curl http://google.com and follow redirect by using '-L' argument.

```
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  name: curl-google
spec:
  taskRef:
    name: curl
  inputs:
    params:
      - name: URL
        value: "http://google.com"
      - name: ARGS
        value: "-L"
```
