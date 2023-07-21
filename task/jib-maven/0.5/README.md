# Jib Maven

This Task builds Java/Kotlin/Groovy/Scala source into a container image using Google's [Jib](https://github.com/GoogleContainerTools/jib) tool.

Jib works with [Maven](https://github.com/GoogleContainerTools/jib/tree/master/jib-maven-plugin) and [Gradle](https://github.com/GoogleContainerTools/jib/tree/master/jib-gradle-plugin) projects, and this template is for Maven projects.

## Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/jib-maven/0.5/raw
```

## Parameters

- **IMAGE**: The name of the image to build
- **MAVEN_IMAGE**: The base image for maven (_default_: `gcr.io/cloud-builders/mvn`)
- **DIRECTORY**: The directory in the source repository where source should be found. (*default: .*)
- **CACHE**: The name of the volume for caching Maven artifacts and
  base image layers (*default: empty-dir-volume*)
- **INSECUREREGISTRY**: Whether to allow insecure registry (_default:_ `false`)
- **CACERTFILE**: CA cert file name containing the certs for TLS verify (_default:_ `service-ca.crt`)

## Workspaces

* **source**: A [Workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md) containing the source to build.
* **sslcertdir**: An [*optional* Workspace](https://github.com/tektoncd/pipeline/blob/v0.17.0/docs/workspaces.md#optional-workspaces) containing your custom SSL certificates to connect to the registry.

## Results

- **IMAGE_DIGEST**: Digest of the image just built.

## Platforms

The Task can be run on `linux/amd64`, `linux/s390x` and `linux/ppc64le` platforms.

For `linux/s390x` and `linux/ppc64le` platforms specify **MAVEN_IMAGE** parameter with `maven:3.6.3-adoptopenjdk-11` value in TaskRun or PipelineRun.

## Usage

This TaskRun runs the Task to fetch a Git repo, and build and push a container
image using Jib (Maven)

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: example-jib-maven
spec:
  taskRef:
    name: jib-maven
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

If you would like to customize the container, configure the `jib-maven-plugin` in your `pom.xml`.
See [setup instructions for Maven](https://github.com/GoogleContainerTools/jib/tree/master/jib-maven-plugin#setup) for more information.
