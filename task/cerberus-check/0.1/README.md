# STARTX

## Cerberus-check

The cerberus-check task execute periodic check of a cerberus server and return a OK when cerberus signal is positive.

### Install the Cerberus-check task

```
kubectl apply -f https://raw.githubusercontent.com/startxfr/tekton-catalog/main/task/cerberus-check/0.1/cerberus-check.yaml
```

### Parameters

| Key             | Default                | Description                                                                        |
| --------------- | ---------------------- | ---------------------------------------------------------------------------------- |
| cerberus_server | `http://cerberus:8080` | Full URL to the cerberus server. Must be internal when inside a kubernetes cluster |
| timeout         | `60`                   | Timeout for the healthcheck performed against the cerberus server                  |
| frequency       | `10`                   | Frequency of the healthcheck in case of bad pulse                                  |

### Workspaces

_This task require no workspace_

## Platforms

The Task can be run on `linux/amd64` platform.

### Usage

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: cerberus-check-test
spec:
  taskRef:
    name: cerberus-check
  params:
  - name: cerberus_server
    value: "http://cerberus.chaos-cerberus.svc.cluster.local:8080"
```