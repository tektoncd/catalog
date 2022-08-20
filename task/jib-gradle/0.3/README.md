# Jib Gradle

This Task builds Java/Kotlin/Groovy/Scala source into a container image using Google's [Jib](https://github.com/GoogleContainerTools/jib) tool.

Jib works with [Gradle](https://github.com/GoogleContainerTools/jib/tree/master/jib-gradle-plugin) and [Maven](https://github.com/GoogleContainerTools/jib/tree/master/jib-maven-plugin) projects, and this template is for Gradle projects.

## Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/jib-gradle/0.3/raw
```

## Parameters

- **BUILDER_IMAGE**: The location of the gradle builder image. (*default: gcr.io/cloud-builders/gradle@sha256:96d6343589392afd9eab8c4463ec899b8b1c972e7cd70678a70a4821c16eb4c9*)
- **IMAGE**: Reference of the image gradle will produce.
- **DIRECTORY**: The directory in the source repository where source should be found. (*default: .*)
- **CACHE**: The name of the volume for caching Gradle artifacts, local Maven repository, and base image layers (*default: empty-dir-volume*)
- **INSECUREREGISTRY**: Whether to allow insecure registry. (*default: "false"*)
- **EXTRA_ARGS**: Provides extra arguments to the gradle jib build (*default: ""*)

## Workspaces

- **source**: A [Workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md) containing the source to build.

## Results

- **IMAGE_DIGEST**: The digest of the image just built.

## Platforms

The Task can be run on `linux/amd64`, `linux/s390x`, and `linux/ppc64le` platforms.

For `linux/s390x` and `linux/ppc64le` platforms specify **BUILDER_IMAGE** parameter with `gradle:5.6.2-jdk11` value in TaskRun or PipelineRun.

## Usage

This TaskRun runs the Task to fetch a Git repo, and build and push a container image using Jib (Gradle).

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: example-jib-gradle
spec:
  taskRef:
    name: jib-gradle
  params:
  - name: IMAGE
    value: gcr.io/my-repo/my-image
  - name: DIRECTORY
    value: ./examples/helloworld
  workspaces:
  - name: source
    persistentVolumeClaim:
      claimName: my-source
```

If you would like to customize the container, configure the `jib-gradle-plugin` in your `build.gradle`.
See [setup instructions for Gradle](https://github.com/GoogleContainerTools/jib/tree/master/jib-gradle-plugin#setup) for more information.
