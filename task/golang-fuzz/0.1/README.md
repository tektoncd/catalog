# Golang Fuzz

This task is a Golang task to fuzz Go projects

## Install the task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/golang-test/0.1/raw
```

### Parameters

* **package**: base package to fuzz test
* **target**: fuzz targets 
* **context**: path to the directory to use as context (default: .)
* **version**: golang version to use (_default:_ latest)
* **flags**: flags to use for `gotip test -fuzz=FuzzFoo` command (_default:_ "")
* **GOOS**: operating system target (_default:_ linux)
* **GOARCH**: architecture target (_default:_ amd64)
* **GO111MODULE**: value of module support (_default:_ auto)
* **GOCACHE**: value for go caching path (_default:_ "")
* **GOMODCACHE**: value for go module caching path (_default:_ "")

### Workspaces

* **source**: A [Workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md) containing the source to fuzz.

### Platforms

The Task can be run on `linux/amd64`, `linux/s390x`, and `linux/ppc64le` platforms.

Specify value for `GOARCH` parameter according to the desired target architecture.

## Usage

This TaskRun runs the Task fuzz the source code on
[`tektoncd/pipeline`](https://github.com/tektoncd/pipeline).

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: fuzz-my-code
spec:
  taskRef:
    name: golang-fuzz
  workspaces:
  - name: source
    persistentVolumeClaim:
      claimName: my-source
  params:
  - name: package
    value: github.com/tektoncd/pipeline
  - name: target
    value: FuzzFoo
```
