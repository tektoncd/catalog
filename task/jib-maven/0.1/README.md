# Jib Maven

This Task builds Java/Kotlin/Groovy/Scala source into a container image using Google's [Jib](https://github.com/GoogleContainerTools/jib) tool.

Jib works with [Maven](https://github.com/GoogleContainerTools/jib/tree/master/jib-maven-plugin) and [Gradle](https://github.com/GoogleContainerTools/jib/tree/master/jib-gradle-plugin) projects, and this template is for Maven projects.

## Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/jib-maven/0.1/raw
```

## Parameters

- **DIRECTORY**: The directory in the source repository where source should be found. (*default: .*)
- **CACHE**: The name of the volume for caching Maven artifacts and
  base image layers (*default: empty-dir-volume*)

## Workspaces

* **source**: A [Workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md) containing the source to build.

## Resources

### Outputs

* **image**: The Docker image name to apply to the newly built image.

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

This TaskRun runs the Task to fetch a Git repo, and build and push a container
image using Jib (Maven)

```yaml
apiVersion: tekton.dev/v1beta1
kind: PipelineResource
metadata:
  name: example-image
spec:
  type: image
  params:
  - name: url
    value: gcr.io/tekton-task-project/my-image
```

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: example-jib-maven
spec:
  taskRef:
    name: jib-maven
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

If you would like to customize the container, configure the `jib-maven-plugin` in your `pom.xml`.
See [setup instructions for Maven](https://github.com/GoogleContainerTools/jib/tree/master/jib-maven-plugin#setup) for more information.
