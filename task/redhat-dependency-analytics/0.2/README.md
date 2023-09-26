# `Red Hat Dependency Analytics`

**Please Note: this Task is only compatible with Tekton Pipelines versions 0.37.5 and greater!**

## Overview
The redhat-dependency-analytics task is an interface between Tekton and Red Hat Dependency Analytics (RHDA) platform. 
It provides vulnerability and compliance analysis for your applications dependencies in your software supply chain.

The redhat-dependency-analytics task for Tekton Pipelines utilizes the [Exhort JavaScript API](https://github.com/RHEcosystemAppEng/exhort-javascript-api), mirroring the functionality of the [VSCode Red Hat Dependency Analytics plugin](https://marketplace.visualstudio.com/items?itemName=redhat.fabric8-analytics).

**Note: Currently this Task only supports Maven (`mvn`), Node (`npm`), Golang (`go mod`) and Python (`pip`) ecosystems, support for other ecosystems will be provided very soon.**

## Prerequisites

Prior to executing the redhat-dependency-analytics task, ensure that you have set up the two necessary components.

### Workspace
Workspace is used as a common filesystem between tasks. It provides a designated area for the input, output, and intermediate files used during the execution of the pipeline by the redhat-dependency-analytics task.

This [sample](samples/workspace.yaml) file can be referred to in order to create a workspace.

The following command can be used to create a workspace from the sample file.

```
kubectl apply -f samples/workspace.yaml -n <NAMESPACE>
```

## Parameters
- **manifest-file-path**: Path to target manifest file (ex. pom.xml, package.json, go.mod, requirements.txt) within workspace to perform analysis upon.
- **output-file-path**: Path to file within workspace where the Red Hat Dependency Analytics report will be saved. `(default: redhat-dependency-analytics-report.json)`
- **rhda-image**: Image where Exhort Javascript API and required dependencies are installed. `(default: quay.io/ecosystem-appeng/exhort-javascript-api:0.1.1-ea.26)`. 
- **python-image**: Image with installed Python interpreter and associated tools (such as pip, pip3, etc.). `(default: python:3.11)`. 
- **use-go-mvs-logic**:  indicate whether to use the Minimal version selection (MVS) algorithm to select a set of module versions to use when building Go packages. Relevant for Go ecosystem only. `(default: false)`. 

List of images for different ecosystem versions can be found [here](https://github.com/RHEcosystemAppEng/exhort-javascript-api/tree/main/docker-image)

## Output
The complete response of Red Hat Dependency Analytics is saved in JSON format within the workspace directory under file name defined by parameter `output-file-name`. 
This response provides both a summary and a comprehensive report detailing all discovered vulnerabilities. 
The provided response may be used by a subsequent task for decision making, such as Passing or Failing a build. 

In the logs, a simplified report summary will be displayed, example:
```
Red Hat Dependency Analytics Report
==================================================
Dependencies
  Total Scanned      :  8 
  Total Direct       :  7 
  Total Transitive   :  1 

Provider: Osv-nvd
  Provider Status    : OK 
  Source: Osv-nvd
    Vulnerabilities
      Total          :  8 
      Direct         :  8 
      Transitive     :  0 
      Critical       :  2 
      High           :  4 
      Medium         :  2 
      Low            :  0 
==================================================
Full report is saved into file: redhat-dependency-analytics-report.json
Task is completed.
```

In case of failure, please refer to the `error.log` file within workspace for more information.

## Installation

### Install task on environment using kubectl
```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/redhat-dependency-analytics/0.2/redhat-dependency-analytics.yaml -n <NAMESPACE>
```

### Install task on environment using tkn
```
tkn hub install task redhat-dependency-analytics -n <NAMESPACE>
```

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

You can apply the specified task to resources such as TaskRun, Pipeline, and PipelineRun using the following configuration:

```
...
...
- name: redhat-dependency-analytics
  taskRef:
    name: redhat-dependency-analytics
  workspaces:
    - name: output
      workspace: output
  params:
    - name: manifest-file-path
      value: /path/to/manifest/file/in/workspace
    - name: output-file-path
      value: /path/to/output/file/in/workspace
    - name: rhda-image
      value: your-image-name:tag
    - name: python-image
      value: your-image-name:tag
    - name: use-go-mvs-logic
      value: false
...
...
```

## Demo

An example PipelineRun and TaskRun are provided in the `samples` directory in order to demonstrate the usage of the redhat-dependency-analytics task. 

### Deployment Instructions:

1. Deploy a new workspace with [workspace.yaml](samples/workspace.yaml), run:
    ```
    kubectl apply -f samples/workspace.yaml -n <NAMESPACE>
    ```

1. Deploy the redhat-dependency-analytics task by utilizing the [redhat-dependency-analytics.yaml](redhat-dependency-analytics.yaml) configuration file. You can initiate it by using the following command:
    ```
    kubectl apply -f redhat-dependency-analytics.yaml -n <NAMESPACE>
    ```
    Alternatively, you can consult the [installation guidelines](#installation) for the task setup instructions.

#### For PipelineRun Example:

1. Deploy the [git-clone](https://hub.tekton.dev/tekton/task/git-clone) Tekton Task to your environment. Refer to the `git-clone` documentation for instructions on setting up the pipeline with the appropriate parameters to align with your GitHub repository.

    **NOTE** that the sample pipeline has been pre-configured to facilitate the cloning of public repositories in a straightforward manner. In this setup, simply providing an HTTPS URL for a public repository is adequate to ensure the functionality of the pipeline.

1. Deploy the pipeline with [pipeline.yaml](samples/pipeline.yaml), run:
    ```
    kubectl apply -f samples/pipeline.yaml -n <NAMESPACE>
    ```

1. In [pipeline-run.yaml](samples/pipeline-run.yaml), first replace `{{ GITHUB_URL }}` with the Github URL to the project repository where the target manifest file resides, next replace `{{ MANIFEST_FILE_PATH }}` with the path to the target manifest file within workspace (e.g., "pom.xml" or "path/to/my/project/pom.xml"). 
Additionally, if you are operating within a Python environment, you have the flexibility to substitute the default value of the `python-image` parameter with a base image that incorporates the specific Python version you prefer. If you are operating within a Go environment, you might prefer to use the Minimal version selection (MVS) algorithm to select a set of module versions to use when building Go packages, in that case, set `use-go-mvs-logic` parameter to true.
Finally create the pipelinerun, run:
    ```
    kubectl apply -f samples/pipeline-run.yaml -n <NAMESPACE>
    ```

#### For TaskRun Example:

1. Store the target manifest file into a desired location inside workspace.

1. In [task-run.yaml](samples/task-run.yaml), replace `{{ MANIFEST_FILE_PATH }}` with the path to the target manifest file within workspace (e.g., "pom.xml" or "path/to/my/project/pom.xml"). Additionally, if you are operating within a Python environment, you have the flexibility to substitute the default value of the `python-image` parameter with a base image that incorporates the specific Python version you prefer. If you are operating within a Go environment, you might prefer to use the Minimal version selection (MVS) algorithm to select a set of module versions to use when building Go packages, in that case, set `use-go-mvs-logic` parameter to true.
Then create the taskrun, run:
    ```
    kubectl apply -f samples/task-run.yaml -n <NAMESPACE>
    ```
