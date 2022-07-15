# Golang Build

This Task is Golang task to build Go projects.

## Install the task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/golang-build/0.1/raw

```


### Parameters

* **package**: base package under test
* **packages**: packages to test (_default:_ ./...)
* **version**: golang version to use for tests (_default:_ latest)
* **flags**: flags to use for `go build` command (_default:_ -v)
* **GOOS**: operating system target (_default:_ linux)
* **GOARCH**: architecture target (_default:_ amd64)
* **GO111MODULE**: value of module support (_default:_ auto)

### Workspaces

* **source**: A [Workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md) containing the source to build.

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

This TaskRun runs the Task to compile commands from
[`tektoncd/pipeline`](https://github.com/tektoncd/pipeline).
`golangci-lint`.

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: build-my-code
spec:
  taskRef:
    name: golang-build
  workspaces:
  - name: source
    persistentVolumeClaim:
      claimName: my-source
  params:
  - name: package
    value: github.com/tektoncd/pipeline
```
