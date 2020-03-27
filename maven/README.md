# Maven

This Task can be used to run a Maven build.

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/maven/maven.yaml
```

## Inputs

### Parameters

- **GOALS**: Maven `goals` to be executed
- **MAVEN_MIRROR_URL**: Maven mirror url (to be inserted into ~/.m2/settings.xml)   
- **PROXY_USER**: Username to login to the proxy server (to be inserted into ~/.m2/settings.xml)
- **PROXY_PASSWORD**: Password to login to the proxy server (to be inserted into ~/.m2/settings.xml)
- **PROXY_HOST**: Hostname of the proxy server (to be inserted into ~/.m2/settings.xml)
- **PROXY_NON_PROXY_HOSTS**: Non proxy hosts to be reached directly bypassing the proxy (to be inserted into ~/.m2/settings.xml)
- **PROXY_PORT**: Port number on which the proxy port listens (to be inserted into ~/.m2/settings.xml)
- **PROXY_PROTOCOL**: http or https protocol whichever is applicable (to be inserted into ~/.m2/settings.xml)

### Resources

* **source**: `git`-type `PipelineResource` specifying the location of the source to build. 

## Usage

This TaskRun runs the Task to fetch a Git repo, and runs a Maven build

```
apiVersion: tekton.dev/v1alpha1
kind: PipelineResource
metadata:
  name: maven-resource-petclinic
spec:
  type: git
  params:
    - name: revision
      value: master
    - name: url
      value: https://github.com/spring-projects/spring-petclinic
```

### With Defaults

```
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  name: maven-run
spec:
  inputs:
    resources:
    - name: source
      resourceRef:
        name: maven-resource-petclinic
  taskRef:
    name: maven
  workspaces:
    - name: maven-settings
      emptyDir: {}
```
---

### With Custom Params

```
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  name: maven-run
spec:
  inputs:
    resources:
    - name: source
      resourceRef:
        name: maven-resource-petclinic
    params:
    - name: MAVEN_MIRROR_URL
      value: "http://localhost:8080/bucketrepo/"
    - name: PROXY_HOST
      value: "proxy.somewhere.com"
    - name: PROXY_PORT
      value: "8080"
    - name: PROXY_USER
      value: "yourusername"
    - name: PROXY_PASSWORD
      value: "yourpassword"
    - name: PROXY_NON_PROXY_HOSTS
      value: "www.google.com|*.example.com"
    - name: PROXY_PROTOCOL
      value: "https"
  taskRef:
    name: maven
```
---
### With Custom /.m2/settings.yaml

A user provided custom `settings.xml` can be used with the Maven Task. To do this we need to mount the `settings.xml` on the Maven Task. 
Following steps demostrate the use of a ConfigMap to mount a custom `settings.xml`.

1. create configmap
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: custom-maven-settings
data:
  settings.xml: |
    <?xml version="1.0" encoding="UTF-8"?>
    <settings>
      <mirrors>
        <mirror>
          <id>maven.org</id>
          <name>Default mirror</name>
          <url>http://repo1.maven.org/maven2</url>
          <mirrorOf>central</mirrorOf>
        </mirror>
      </mirrors>
    </settings>

```
or 
```
oc create configmap custom-maven-settings --from-file=settings.xml
```

2. create TaskRun
```
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  name: maven-run
spec:
  inputs:
    resources:
      - name: source
        resourceRef:
          name: maven-resource-petclinic
    taskRef:
      name: maven
    workspaces:
    - name: maven-settings
      configMap:
        name: custom-maven-settings
```
