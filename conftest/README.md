# Conftest

These tasks make it possible to use [Conftest](https://github.com/instrumenta/conftest) within
your Tekton pipelines. Conftest is a tool for testing configuration files using [Open Policy Agent](https://openpolicyagent.org).

## Installation

In order to use Conftest with Tekton you need to first install the task.

```console
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/conftest/conftest.yaml
```

Conftest also has a Helm plugin, which redners the Helm chart before applying the policy. For that task use:

```console
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/conftest/helm-conftest.yaml
```


## Usage

Once installed, the task can be used as follows:

```yaml
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  name: conftest-example
spec:
  taskRef:
    name: conftest
  inputs:
    resources:
    - name: source
      resourceSpec:
        type: git
        params:
        - name: revision
          value: master
        - name: url
          value: https://github.com/instrumenta/conftest.git
    params:
    - name: files
      value: examples/kubernetes/deployment.yaml
    - name: policy
      value: examples/kubernetes/policy
```

Note that the above respository contains both a configuration file we want to test (`examples/kubernetes/deployment.yaml`) and a directory (`examples/kubernetes/policy`) containing OPA policy files. When using the task you would provide the details of the repository you want to test.

If you apply the above `TaskRun` you can see the output in the `taskrun` logs. For example:

```console
$ tkn taskrun logs conftest-example -f
[git-source-source-6pt9g] {"level":"warn","ts":1566067534.0510817,"logger":"fallback-logger","caller":"logging/config.go:69","msg":"Fetch GitHub commit ID from kodata failed: \"ref: refs/heads/master\" is not a valid GitHub commit ID"}
[git-source-source-6pt9g] {"level":"info","ts":1566067534.989535,"logger":"fallback-logger","caller":"git/git.go:102","msg":"Successfully cloned https://github.com/instrumenta/conftest.git @ master in path /workspace/source"}
[conftest] FAIL - examples/kubernetes/deployment.yaml - Containers must not run as root in Deployment hello-kubernetes
[conftest] FAIL - examples/kubernetes/deployment.yaml - Deployment hello-kubernetes must provide app/release labels for pod selectors
[conftest] FAIL - examples/kubernetes/deployment.yaml - hello-kubernetes must include Kubernetes recommended labels: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels

container step-conftest has failed  : Error
```

## Inputs

### Parameters

* **files**: The files to test against the specified policies
* **policy**: Where to find the policies (_default:_ `policy`)
* **output**: Which output format to use (_default:_ `stdout`)
* **args**: An array of additional arguments to pass to Conftest (_default `[]`_)

### Resources

* **source**: A `git`-type `PipelineResource` specifying the location of the
  source to build.


## Helm usage


Once installed, the Helm task can be used as follows:

```yaml
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  name: helm-conftest-example
spec:
  taskRef:
    name: helm-conftest
  inputs:
    resources:
    - name: source
      resourceSpec:
        type: git
        params:
        - name: revision
          value: master
        - name: url
          value: https://github.com/helm/charts.git
    params:
    - name: chart
      value: stable/mysql
    - name: policy
      value: stable/mysql/policy
```

## Inputs

### Parameters

* **chart**: The chart to test against the specified policies (_default:_ `.`)
* **policy**: Where to find the policies (_default:_ `policy`)
* **output**: Which output format to use (_default:_ `stdout`)
* **args**: An array of additional arguments to pass to Conftest (_default `[]`)

### Resources

* **source**: A `git`-type `PipelineResource` specifying the location of the
  source to build.



