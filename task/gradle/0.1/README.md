# Gradle

This Task can be used to run a Gradle build on a gradle project.

## Install the Task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/gradle/0.1/raw
```

## Parameters

- **GRADLE_IMAGE**: The base image for gradle (_default_: `gradle:6.9.0-jdk8`)
- **PROJECT_DIR**: The project directory containing `build.gradle` (_default_: `.`)
- **TASKS**: The gradle tasks to run (_default_: `build`)

## Workspaces

- **source**: `PersistentVolumeClaim`-type so that the volume can be shared among `git-clone` and `gradle` task

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: gradle-source-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
```

## Platforms

The Task can be run on `linux/amd64`, `linux/s390x` and `linux/ppc64le` platforms.

## Usage

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: run-gradle-build
spec:
  taskRef:
    name: gradle
  workspaces:
    - name: source
      persistentVolumeClaim:
        claimName: my-source
  params:
    - name: PROJECT_DIR
      value: my-workspace
```
