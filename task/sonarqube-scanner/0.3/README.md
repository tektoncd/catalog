# SonarQube

SonarQube™ is the leading tool for continuously inspecting the Code Quality and Security™ of your codebases, all while empowering development teams. Analyze over 25 popular programming languages including C#, VB.Net, JavaScript, TypeScript and C++. It detects bugs, vulnerabilities and code smells across project branches and pull requests.

The following task can be used to perform static analysis on the source code provided the SonarQube server is hosted.

For creating your own `sonar-project.properties` please follow the guide [here](https://docs.sonarqube.org/latest/analysis/analysis-parameters/). Sample properties file can be found [here](./samples/sonar-project.properties)

## Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/sonarqube-scanner/0.3/raw
```

## Pre-requisite

Install the `git-clone` task from the catalog

```
https://api.hub.tekton.dev/v1/resource/tekton/task/git-clone/0.7/raw
```

## Parameters

- **SONAR_HOST_URL**: SonarQube server URL
- **SONAR_PROJECT_KEY**: Project's unique key
- **PROJECT_VERSION**: Version of the project (_Default_: 1.0)
- **SOURCE_TO_SCAN**: Comma-separated paths to directories containing main source files (_Default_: ".")
- **SONAR_ORGANIZATION**: The organization in sonarqube where the project exists
- **SONAR_SCANNER_IMAGE**: The sonarqube scanner CLI image which will run the scan (_Default_: docker.io/sonarsource/sonar-scanner-cli:4.6)

> _Note_ : Parameters are provided in that case when we want to override the corresponding values in `sonar-project.properties` or there is no `sonar-project.properties` present for the project which needs to be analyzed

## Workspaces

- **source**: `PersistentVolumeClaim`-type so that volume can be shared among git-clone and sonarqube task. Sample PVC can be found [here](../0.3/tests/resources.yaml)
- **sonar-settings**: To mount the `sonar-project.properties` via the `ConfigMap`. It's an optional workspace.

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

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

1. `sonar-project.properties` present in Github Repository. For example :- following [repo](https://github.com/vinamra28/sonartest) contains the properties file and Sonar Host URL needs to be updated via the `params`.
   The sample run for this scenario can be found [here](../0.1/samples/run.yaml)

2. In case when no `sonar-project.properties` file is present then above parameters are mandatory to create a `sonar-project.properties` file with the required fields or the file can be mounted via the `ConfigMap`.
