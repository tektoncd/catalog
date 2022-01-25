# Sonar Qualitygate

This task checks if a SonarQube/Cloud quality gate has the status OK or not. If the status is not OK it will fail. Authentication is optional and provided by a workspace (probably a secret).

## Install the Task

```bash
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/sonar-qualitygate/0.1/robot-framework.yaml
```

## Workspaces

- **token**: Optional workspace containing a authentication token. Use a secret with the key `token`.

## Parameters

- **IMAGE**: Optional: Default uses alpine and installs curl and jq during runtime. It's also possible to use your own image.
- **SONAR_HOST_URL**: Host URL where the sonarqube server is running
- **SONAR_PROJECT_KEY**: Project's unique key

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

Basic usage without installing extra requirements or using a variables file:

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: example-run
spec:
  taskRef:
    name: sonar-qualitygate
  params:          
    - name: SONAR_HOST_URL
      value: "https://sonarcloud.io"
    - name: SONAR_PROJECT_KEY
      value: "sonarqube-scanner"
```

Using a secret that contains the authentication token

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: example-run
spec:
  taskRef:
    name: sonar-qualitygate
  params:          
    - name: SONAR_HOST_URL
      value: "https://sonarcloud.io"
    - name: SONAR_PROJECT_KEY
      value: "sonarqube-scanner"
  workspaces:
  - name: token
    secret:
      secretName: sonarToken
```
