# Tekton Catalog

This repository contains a catalog of `Task` resources (and someday
`Pipeline`s and `Resource`s), which are designed to be reusable in many
pipelines.

Each `Task` is provided in a separate directory along with a README.md and a
Kubernetes manifest, so you can choose which `Task`s to install on your
cluster.

## `Task` Kinds

There are two kinds of `Task`s:

 1. `ClusterTask` with a Cluster scope, which can be installed by a cluster
    operator and made available to users in all namespaces
 2. `Task` with a Namespace scope, which is designed to be installed and used
    only within that namespace.

`Task`s in this repo are namespace-scoped `Task`s, but can be installed as
`ClusterTask`s by changing the `kind`.

## Using `Task`s

First, install a `Task` onto your cluster:

```
$ kubectl apply -f bazel.yaml
task.tekton.dev/bazel created
```

You can see which `Task`s are installed using `kubectl` as well:

```
$ kubectl get tasks
NAME    AGE
bazel   3s
```

*OR*

```
$ kubectl get clustertasks
NAME            AGE
cluster-bazel   3s
```

With the `Task` installed, you can define a `TaskRun` that runs that `Task`,
being sure to provide values for required input parameters and resources:

```
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  name: example-run
spec:
  taskRef:
    name: bazel
  inputs:
    params:
    - name: TARGET
      value: //path/to/image:publish
    resources:
    - name: source
      resourceSpec:
        type: git
        params:
        - name: url
          value: https://github.com/my-user/my-repo
```

Next, create the `TaskRun` you defined:

```
$ kubectl apply -f example-run.yaml
taskrun.tekton.dev/example-run created
```

You can check the status of the `TaskRun` using `kubectl`:

```
$ kubectl get taskrun example-run -oyaml
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  name: example-run
spec:
  ...
status:
  completionTime: "2019-04-25T18:10:09Z"
  conditions:
  - lastTransitionTime: "2019-04-25T18:10:09Z"
    status: True
    type: Succeeded
...
```

## Contributing and Support

If you want to contribute to this repository, please see our [contributing](./CONTRIBUTING.md) guidelines.

If you are looking for support, enter an [issue](https://github.com/tektoncd/catalog/issues/new) or join our [Slack workspace](https://tektoncd.slack.com/)
