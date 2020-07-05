# Jib Gradle

This Task builds Java/Kotlin/Groovy/Scala source into a container image using Google's [Jib](https://github.com/GoogleContainerTools/jib) tool.

Jib works with [Gradle](https://github.com/GoogleContainerTools/jib/tree/master/jib-gradle-plugin) and [Maven](https://github.com/GoogleContainerTools/jib/tree/master/jib-maven-plugin) projects, and this template is for Gradle projects.

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/jib-gradle/jib-gradle.yaml
```


## Parameters

- **DIRECTORY**: The directory in the source repository where source should be found. (*default: .*)
- **CACHE**: The name of the volume for caching Gradle artifacts, local Maven repository, and base image layers (*default: empty-dir-volume*)

## Workspaces

* **source**: A `git`-type `PipelineResource` specifying the location of the
  source to build.

## Resources

### Outputs

* **image**: The Docker image name to apply to the newly built image.

## Usage

This TaskRun runs the Task to fetch a Git repo, and build and push a container
image using Jib (Gradle)

```
apiVersion: tekton.dev/v1alpha1
kind: PipelineResource
metadata:
  name: example-image
spec:
  type: image
  params:
  - name: url
    value: gcr.io/tekton-task-project/my-image
```

```
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: example-jib-gradle
spec:
  taskRef:
    name: jib-gradle
  params:
  - name: DIRECTORY
    value: ./examples/helloworld
  workspaces:
  - name: source
    persistentVolumeClaim:
      claimName: my-source
  resources:
    outputs:
    - name: image
      resourceRef:
        name: example-image
```

If you would like to customize the container, configure the `jib-gradle-plugin` in your `build.gradle`.
See [setup instructions for Gradle](https://github.com/GoogleContainerTools/jib/tree/master/jib-gradle-plugin#setup) for more information.
