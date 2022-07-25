# Golang Test

This task is a Golang task to test Go projects.

## Install the task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/golang-test/0.3/golang-test.yaml
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
* **GOCACHE**: value for go caching path (_default:_ "")
* **GOMODCACHE**: value for go module caching path (_default:_ "")
* **CGOENABLED**: go env. enables cgo
* **GOPRIVATE**: go env. private modules to be fetched from original source
* **GIT_ALLOW_PROTOCOL**: list of vcs schemes to download module dependencies
* **git_config_add**: git configuration to add
* **pkgs**: linux packages to install from the apt library
* **pkg_source**: additional linux package sources to fetch apt packages from
* **GOPROXY**: [Proxy settings](https://go.dev/ref/mod#goproxy-protocol) for Go dependencies (default: empty, not enabled)


### [Workspaces](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md)

* **source**: Source to build.
* **ssh-directory**: ssh secrets to authorize module downloads with git

## Platforms

The Task can be run on `linux/arm64`, `linux/amd64`, `linux/s390x` and `linux/ppc64le` platforms.

Specify value for `GOARCH` parameter according to the desired target architecture.
Do not use `-race` flag in `flags` parameter for `linux/s390x` platform.

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
