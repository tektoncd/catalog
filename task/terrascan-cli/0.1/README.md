
# Terrascan Installation Tekton Task

kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/terrascan-cli/0.1/raw



## Overview
This Tekton Task, named "terrascan-install," is designed to install Terrascan CLI in your CI/CD pipelines. Terrascan is a tool to detect security vulnerabilities in your Infrastructure as Code (IaC) files.

## Task Details
- **Name:** terrascan-install
- **Version:** 1.0
- **Description:** Installs Terrascan CLI in the Tekton environment.
- **Parameters:**
  - `TERRASCAN_VERSION` (string): Terrascan version to install. Default is "v1.10.0."

## Usage
1. Ensure you have Tekton installed in your Kubernetes cluster.
2. Apply this Tekton Task YAML to your cluster using `kubectl apply -f terrascan-install-task.yaml`.
3. Integrate the "terrascan-install" task into your Tekton Pipelines as needed.

## Parameters
1. **TERRASCAN_VERSION:**
   - *Description:* Terrascan version to install.
   - *Type:* String
   - *Default:* "v1.10.0"

## Example Tekton Pipeline Usage
```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: terrascan-pipeline
spec:
  tasks:
    - name: install-terrascan
      taskRef:
        name: terrascan-install
      params:
        - name: TERRASCAN_VERSION
          value: "v1.11.0"
