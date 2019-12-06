# Golang tasks

These Tasks are Golang task to build, test and validate Go projects.

## Install the tasks

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/golang/lint.yaml
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/golang/build.yaml
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/golang/tests.yaml
```

## `golangci-lint`

### Inputs

#### Parameters

* **package**: base package under validation
* **flags**: flags to use for `golangci-lint` command (_default:_--verbose)
* **version**: golangci-lint version to use (_default:_ v1.16)
* **GOOS**: operating system target (_default:_ linux)
* **GOARCH**: architecture target (_default:_ amd64)
* **GO111MODULE**: value of module support (_default:_ auto)

#### Resources

* **source**: A `git`-type `PipelineResource` specifying the location of the
  source to build.

### `golang-build`

### Inputs

#### Parameters

* **package**: base package under test
* **packages**: packages to test (_default:_ ./...)
* **version**: golang version to use for tests (_default:_ latest)
* **flags**: flags to use for `go test` command (_default:_ -v)
* **GOOS**: operating system target (_default:_ linux)
* **GOARCH**: architecture target (_default:_ amd64)
* **GO111MODULE**: value of module support (_default:_ auto)

#### Resources

* **source**: A `git`-type `PipelineResource` specifying the location of the
  source to build.

### `golang-test`

### Inputs

#### Parameters

* **package**: base package to build in
* **packages**: packages to test (_default:_ ./cmd/...)
* **version**: golang version to use for builds (_default:_ latest)
* **flags**: flags to use for `go test` command (_default:_ -race -cover -v)
* **GOOS**: operating system target (_default:_ linux)
* **GOARCH**: architecture target (_default:_ amd64)
* **GO111MODULE**: value of module support (_default:_ auto)

#### Resources

* **source**: A `git`-type `PipelineResource` specifying the location of the
  source to build.

## Usage

### `golangci-lint`

This TaskRun runs the Task to validate
[`tektoncd/pipeline`](https://github.com/tektoncd/pipeline) `pkg` package with
`golangci-lint`.

```yaml
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  name: lint-my-code
spec:
  taskRef:
    name: golangci-lint
  inputs:
    resources:
    - name: source
      resourceSpec:
        type: git
        params:
        - name: url
          value: https://github.com/tektoncd/pipeline
    params:
    - name: package
      value: github.com/tektoncd/pipeline
    - name: flags
      value: --verbose
```

### `golang-test`

This TaskRun runs the Task to run unit-tests on
[`tektoncd/pipeline`](https://github.com/tektoncd/pipeline).

```yaml
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  name: test-my-code
spec:
  taskRef:
    name: golang-test
  inputs:
    resources:
    - name: source
      resourceSpec:
        type: git
        params:
        - name: url
          value: https://github.com/tektoncd/pipeline
    params:
    - name: package
      value: github.com/tektoncd/pipeline
    - name: packages
      value: ./pkg/...
```

### `golang-build`

This TaskRun runs the Task to compile commands from
[`tektoncd/pipeline`](https://github.com/tektoncd/pipeline).
`golangci-lint`.

```yaml
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  name: build-my-code
spec:
  taskRef:
    name: golang-build
  inputs:
    resources:
    - name: source
      resourceSpec:
        type: git
        params:
        - name: url
          value: https://github.com/tektoncd/pipeline
    params:
    - name: package
      value: github.com/tektoncd/pipeline
```
