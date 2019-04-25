## Bazel

This tasks builds source into a container image using the [Bazel build
tool](https://bazel.build), and [Bazel's container image
support](https://github.com/bazelbuild/rules_docker).

This assumes the source repo in question is using the
[`container_push`](https://github.com/bazelbuild/rules_docker/#container_push-1)
rule to build and push a container image. For example:

```
container_push(
  name = "push",
  format = "Docker", # Or "OCI"
  image = ":image",
  registry = "gcr.io",
  repository = "my-project/my-app",
  stamp = True,
)
```

This target instructs Bazel to build and push a container image containing the
application defined by the `:image` target, based on a suitable base image.

The `rules_docker` repo defines build rules to construct images for a variety of
popular programming languages, like
[Python](https://github.com/bazelbuild/rules_),
[Java](https://github.com/bazelbuild/rules_docker/#java_image),
[Go](https://github.com/bazelbuild/rules_docker/#go_image) and many more.

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/bazel/bazel.yaml
```

## Inputs

### Parameters

* **TARGET**: The Bazel `container_push` target to run to build and push the
  container image.

### Resources

* **source**: A `git`-type `PipelineResource` specifying the location of the
  source to build.

## Usage

This TaskRun runs the Task to fetch a Git repo, and build and push a container
image using Bazel.

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
