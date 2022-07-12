# Tekton Catalog

**If you want `v1alpha1` resources, you need to go to the
[`v1alpha1`](https://github.com/tektoncd/catalog/tree/v1alpha1)
branch. The
[`main`](https://github.com/tektoncd/catalog/tree/main) branch
is synced with
[`v1beta1`](https://github.com/tektoncd/catalog/tree/v1beta1) since
2020, 19th June.**

This repository contains a catalog of `Task` resources (and someday
`Pipeline`s and `Resource`s), which are designed to be reusable in many
pipelines.

Each `Task` is provided in a separate directory along with a README.md and a
Kubernetes manifest, so you can choose which `Task`s to install on your
cluster. A directory can hold one task and multiple versions.

_See [our project roadmap](roadmap.md)._

#### [Hub](https://hub.tekton.dev/) provides an easy way to search and discover all Tekton resources

## Catalog Structure

1. Each resource follows the following structure

    ```
    ./task/                     👈 the kind of the resource

        /argocd                 👈 definition file must have same name
           /0.1
             /OWNERS            👈 owners of this resource
             /README.md
             /argocd.yaml       👈 the file name should match the resource name
             /samples/deploy-to-k8s.yaml
           /0.2/...

        /golang-build
           /OWNERS
           /README.md
           /0.1
             /README.md
             /golang-build.yaml
             /samples/golang-build.yaml
    ```

2. Resource YAML file includes following changes
  *  Labels include the version of the resource.
  *  Annotations include `minimum pipeline version` supported by the resource,
     `tags` associated with the resource and `displayName` of the resource

  ```yaml

   labels:
      app.kubernetes.io/version: "0.1"                 👈 Version of the resource

    annotations:
      tekton.dev/pipelines.minVersion: "0.12.1"        👈 Min Version of pipeline resource is compatible
      tekton.dev/categories: CLI		        👈 Comma separated list of categories
      tekton.dev/tags: "ansible, cli"                  👈 Comma separated list of tags
      tekton.dev/displayName: "Ansible Tower Cli"      👈 displayName can be optional
      tekton.dev/platforms: "linux/amd64,linux/s390x"  👈 Comma separated list of platforms, can be optional

  spec:
    description: |-
      ansible-tower-cli task simplifies
      workflow, jobs, manage users...                  👈 Summary

      Ansible Tower (formerly ‘AWX’) is a ...

  ```

**Note** : Categories are a generalized list and are maintained by Hub. To add new categories, please follow the procedure mentioned [here](https://github.com/tektoncd/hub/blob/main/docs/ADD_NEW_CATEGORY.md).

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
$ kubectl apply -f golang/build.yaml
task.tekton.dev/golang-build created
```

You can see which `Task`s are installed using `kubectl` as well:

```
$ kubectl get tasks
NAME           AGE
golang-build   3s
```

With the `Task` installed, you can define a `TaskRun` that runs that `Task`,
being sure to provide values for required input parameters and resources:

```
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: example-run
spec:
  taskRef:
    name: golang-build
  params:
  - name: package
    value: github.com/tektoncd/pipeline
  workspaces:
  - name: source
    persistentVolumeClaim:
      claimName: my-source
```

Next, create the `TaskRun` you defined:

```
$ kubectl apply -f example-run.yaml
taskrun.tekton.dev/example-run created
```

You can check the status of the `TaskRun` using `kubectl`:

```
$ kubectl get taskrun example-run -oyaml
apiVersion: tekton.dev/v1beta1
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

### Using `Task`s through Bundles

[Tekton Bundles](https://tekton.dev/docs/pipelines/pipelines/#tekton-bundles) are an alpha feature of Tekton pipelines that allows storing `Tasks` as bundles in a container registry, instead of as custom resources in etcd in a Kubernetes cluster.
With Tekton Bundles are enabled, it is possible to reference any task in the catalog without installing it first.
Tasks are available at [`gcr.io/tekton-releases/catalog/upstream/<task-name>:<task-version>`](https://console.cloud.google.com/gcr/images/tekton-releases/GLOBAL/catalog/upstream?gcrImageListsize=100).
For example:

```
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: example-run
spec:
  taskRef:
    name: golang-build
    bundle: gcr.io/tekton-releases/catalog/upstream/golang-build:0.1
  params:
  - name: package
    value: github.com/tektoncd/pipeline
  workspaces:
  - name: source
    persistentVolumeClaim:
      claimName: my-source
```

## Contributing and Support

If you want to contribute to this repository, please see our [contributing](./CONTRIBUTING.md) guidelines.

If you are looking for support, enter an [issue](https://github.com/tektoncd/catalog/issues/new) or join our [Slack workspace](https://github.com/tektoncd/community/blob/main/contact.md#slack)

## Status of the Project

This project is still under active development, so you might run into
[issues](https://github.com/tektoncd/catalog/issues). If you do,
please don't be shy about letting us know, or better yet, contribute a
fix or feature. Its folder structure is not yet set in stone either.

_See [our project roadmap](roadmap.md)._
