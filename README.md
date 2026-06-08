# Tekton Catalog

**If you want `v1alpha1` resources, you need to go to the
[`v1alpha1`](https://github.com/tektoncd/catalog/tree/v1alpha1)
branch. The
[`main`](https://github.com/tektoncd/catalog/tree/main) branch
is synced with
[`v1beta1`](https://github.com/tektoncd/catalog/tree/v1beta1) since
2020, 19th June.**

This repository contains a catalog of `Task` and `Pipeline` resources
(and `StepAction`s), which are designed to be reusable in many
pipelines.

Each `Task` is provided in a separate directory along with a README.md and a
Kubernetes manifest, so you can choose which `Task`s to install on your
cluster. A directory can hold one task and multiple versions.

_See [our project roadmap](roadmap.md)._

## Discovering resources

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/tekton-catalog-tasks)](https://artifacthub.io/packages/search?repo=tekton-catalog-tasks)

The recommended way to search and discover Tekton resources is
[**Artifact Hub**](https://artifacthub.io/packages/search?kind=7). The tasks
in this catalog are published there under the
[`tekton-catalog-tasks`](https://artifacthub.io/packages/search?repo=tekton-catalog-tasks)
repository, and individual maintained tasks (e.g.
[`git-clone`](https://artifacthub.io/packages/tekton-task/git-clone/git-clone))
are increasingly published from their own repositories.

> [!WARNING]
> The previous [Tekton Hub](https://hub.tekton.dev/) (`hub.tekton.dev`) is
> **deprecated** and the hosted service is **no longer running**. Use
> [Artifact Hub](https://artifacthub.io/packages/search?kind=7) instead.

## Catalog Structure

1. Each resource follows the following structure

    ```plaintext
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
      tekton.dev/categories: CLI                       👈 Comma separated list of categories
      tekton.dev/tags: "ansible, cli"                  👈 Comma separated list of tags
      tekton.dev/displayName: "Ansible Tower Cli"      👈 displayName can be optional
      tekton.dev/platforms: "linux/amd64,linux/s390x"  👈 Comma separated list of platforms, can be optional

  spec:
    description: |-
      ansible-tower-cli task simplifies
      workflow, jobs, manage users...                  👈 Summary

      Ansible Tower (formerly ‘AWX’) is a ...

  ```

**Note** : Categories are a generalized list. The historical list and the procedure to add new categories are documented in the (now archived) [`tektoncd/hub`](https://github.com/tektoncd/hub/blob/main/docs/ADD_NEW_CATEGORY.md) repository.

## Using `Task`s

First, install a `Task` onto your cluster:

```sh
$ kubectl apply -f golang/build.yaml
task.tekton.dev/golang-build created
```

You can see which `Task`s are installed using `kubectl` as well:

```sh
$ kubectl get tasks
NAME           AGE
golang-build   3s
```

With the `Task` installed, you can define a `TaskRun` that runs that `Task`,
being sure to provide values for required input parameters and resources:

```yaml
apiVersion: tekton.dev/v1
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

```sh
$ kubectl apply -f example-run.yaml
taskrun.tekton.dev/example-run created
```

You can check the status of the `TaskRun` using `kubectl`:

```sh
$ kubectl get taskrun example-run -oyaml
apiVersion: tekton.dev/v1
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

[Tekton Bundles](https://tekton.dev/docs/pipelines/pipelines/#tekton-bundles) allow storing `Task`s as bundles in a container registry, instead of as custom resources in a Kubernetes cluster.
With bundles, it is possible to reference any task in the catalog without installing it first, using the [bundle resolver](https://tekton.dev/docs/pipelines/bundle-resolver/).
Tasks are available at [`ghcr.io/tektoncd/catalog/upstream/tasks/<task-name>:<task-version>`](https://github.com/orgs/tektoncd/packages?q=&tab=packages&q=).
For example:

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: example-run
spec:
  taskRef:
    resolver: bundles
    params:
    - name: bundle
      value: ghcr.io/tektoncd/catalog/upstream/tasks/golang-build:0.1
    - name: name
      value: golang-build
    - name: kind
      value: task
  params:
  - name: package
    value: github.com/tektoncd/pipeline
  workspaces:
  - name: source
    persistentVolumeClaim:
      claimName: my-source
```

## Quick Start (Development)

```bash
make setup  # one-command setup: installs pre-commit hooks and linters
make lint   # run all linters (yamllint + gofmt)
make test TASK=git-clone VERSION=0.9  # run e2e test for a single task
```

## Contributing and Support

If you want to contribute to this repository, please see our [contributing](./CONTRIBUTING.md) guidelines.

If you are looking for support, enter an [issue](https://github.com/tektoncd/catalog/issues/new) or join our [Slack workspace](https://github.com/tektoncd/community/blob/main/contact.md#slack)

## Status of the Project

> [!NOTE]
> This catalog is **not deprecated**, but it is **in the process of
> changing**. The project is moving toward a **distributed catalog** model
> — individual resources published from their own repositories (see
> [`tektoncd-catalog`](https://github.com/tektoncd-catalog)) and discovered
> through [Artifact Hub](https://artifacthub.io/packages/search?kind=7),
> rather than a single monolithic repository. A TEP formalizing this
> direction and the associated migration path is being prepared, and the
> [roadmap](roadmap.md) is being refreshed accordingly. Expect changes to
> how resources are versioned, maintained, and contributed. Follow along
> (or get involved) via the
> [issues](https://github.com/tektoncd/catalog/issues) and the
> [Tekton community meetings](https://github.com/tektoncd/community/blob/main/contact.md).

You might run into [issues](https://github.com/tektoncd/catalog/issues) — if
you do, please don't be shy about letting us know, or better yet, contribute a
fix or feature.

_See [our project roadmap](roadmap.md)._
