# Golang Test

This task is a Golang task to test Go projects.

## Install the task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/golang-test/0.1/raw
```

### Parameters

* **package**: base package to build in
* **packages**: packages to test (_default:_ ./cmd/...)
* **context**: path to the directory to use as context (default: .)
* **version**: golang version to use for builds (_default:_ latest)
* **flags**: flags to use for `go test` command (_default:_ -race -cover -v)
* **GOOS**: operating system target (_default:_ linux)
* **GOARCH**: architecture target (_default:_ amd64)
* **GO111MODULE**: value of module support (_default:_ auto)

### Workspaces

* **source**: A [Workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md) containing the source to build.

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

This TaskRun runs the Task to run unit-tests on
[`tektoncd/pipeline`](https://github.com/tektoncd/pipeline).

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: test-my-code
spec:
  taskRef:
    name: golang-test
  workspaces:
  - name: source
    persistentVolumeClaim:
      claimName: my-source
  params:
  - name: package
    value: github.com/tektoncd/pipeline
  - name: packages
    value: ./pkg/...
```
