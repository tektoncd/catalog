# SonarQube

SonarQube™ is the leading tool for continuously inspecting the Code Quality and Security™ of your codebases, all while empowering development teams. Analyze over 25 popular programming languages including C#, VB.Net, JavaScript, TypeScript and C++. It detects bugs, vulnerabilities and code smells across project branches and pull requests.

The following task can be used to perform static analysis on the source code provided the SonarQube server is hosted.

For creating your own `sonar-project.properties` please follow the guide [here](https://docs.sonarqube.org/latest/analysis/analysis-parameters/). Sample properties file can be found [here](./examples/sonar-project.properties)

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/sonarqube/sonarqube.yaml
```

## Pre-requisite

Install the `git-clone` task from the catalog

```
https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/git/git-clone.yaml
```

## Parameters

- **SONAR_HOST_URL**: Host URL where the sonarqube server is running
- **SONAR_PROJECT_KEY**: Project's unique key

> _Note_ : Parameters are provided in that case when we want to override the corresponding values in `sonar-project.properties` or there is no `sonar-project.properties` present for the project which needs to be analyzed

## Workspaces

- **source-dir**: `PersistentVolumeClaim`-type so that volume can be shared among git-clone and sonarqube task. Sample PVC can be found [here](./examples/pvc.yaml)
- **sonar-settings**: To mount the `sonar-project.properties` via the `ConfigMap`. (_Default_ : `emptyDir:{}`)

  To mount via the `ConfigMap`:

  ```
  kubectl create configmap sonar-properties --from-file="sonar-project.properties"
  ```

## Running SonarQube Server locally using Docker

1. Boot SonarQube

   ```
   docker run --name="sonarqube" -d sonarqube
   ```

2. Get the IP address exposed by docker image to access sonarqube server

   ```
   docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <container_id or container_name>
   ```

Sample IPAddress we will obtain using above command is like http://172.17.0.2:9000

## Usage

1. `sonar-project.properties` present in Github Repository. For example :- following [repo](https://github.com/vinamra28/sonartest) contains the properties file and Sonar Host URL needs to be updated via the `params`.
   The sample run for this scenario can be found [here](./examples/run.yaml)

2. In case when no `sonar-project.properties` file is present then above two parameters are mandatory to create a `sonar-project.properties` file with the required fields or the file can be mounted via the `ConfigMap`.

```
---
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: sonarqube-pipeline
spec:
  workspaces:
    - name: shared-workspace
    - name: sonar-settings
  tasks:
    - name: fetch-repository
      taskRef:
        name: git-clone
      workspaces:
        - name: output
          workspace: shared-workspace
      params:
        - name: url
          value: https://github.com/vinamra28/replace-tokens-plugin
        - name: subdirectory
          value: ""
        - name: deleteExisting
          value: "true"
    - name: code-analysis
      taskRef:
        name: sonarqube-scanner
      runAfter:
        - fetch-repository
      params:
        - name: SONAR_HOST_URL
          value: http://172.17.0.2:9000
        - name: SONAR_PROJECT_KEY
          value: testapp
      workspaces:
        - name: source-dir
          workspace: shared-workspace
        - name: sonar-settings
          workspace: sonar-settings
---
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: sonarqube-run
spec:
  pipelineRef:
    name: sonarqube-pipeline
  workspaces:
    - name: shared-workspace
      persistentvolumeclaim:
        claimName: sonar-source-pvc
    - name: sonar-settings
      emptyDir: {}
```
