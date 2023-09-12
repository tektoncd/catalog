# `Red Hat Dependency Analytics`

**Please Note: this Task is only compatible with Tekton Pipelines versions 0.37.5 and greater!**

## Overview
The redhat-dependency-analytics task is an interface between Tekton and Red Hat Dependency Analytics (RHDA) platform version `0.7.0-alpha`. 
It provides vulnerability and compliance analysis for your applications dependencies in your software supply chain.

The redhat-dependency-analytics task for Tekton Pipelines utilizes the [Exhort JavaScript API](https://github.com/RHEcosystemAppEng/exhort-javascript-api), mirroring the functionality of the [VSCode Red Hat Dependency Analytics plugin](https://marketplace.visualstudio.com/items?itemName=redhat.fabric8-analytics).

**Note: Currently this Task only supports Maven and NPM ecosystems, support for other ecosystems will be provided very soon.**

## Prerequisite

Prior to executing the redhat-dependency-analytics task, ensure that you have set up the two necessary components.

### 1. Workspace
Workspace is used as a common filesystem between tasks. It provides a designated area for the input, output, and intermediate files used during the execution of the pipeline by the redhat-dependency-analytics task.

This [sample](samples/workspace.yaml) file can be referred to in order to create a workspace.

The following command can be used to create a workspace from the sample file.

```
kubectl apply -f samples/workspace.yaml -n <NAMESPACE>
```

### 2. Secret
The redhat-dependency-analytics task uses the `EXHORT_SNYK_TOKEN` token to authenticate with Snyk (vulnerability data provider).
This Token must be saved in a secret by the name of `exhort`.<br />
To generate a new Snyk token please visit the following [link](https://app.snyk.io/login?utm_campaign=Code-Ready-Analytics-2020&utm_source=code_ready&code_ready=FF1B53D9-57BE-4613-96D7-1D06066C38C9).

This [sample](samples/secret.yaml) file can be referred to in order to create a secret, replace `{{ EXHORT_SNYK_TOKEN }}` with the generated Snyk token before running.

The following command can be used to create a secret from the sample file.

```
kubectl apply -f samples/secret.yaml -n <NAMESPACE>
```

## Parameters
- **manifest-file-path**: Path to target manifest file (ex. pom.xml, package.json etc.) within the project directory to perform analysis upon.
- **project-directory-path**: Path to directory within workspace where all project files are located or where project has been cloned to. `(default: project-package)`
- **output-file-path**: Path to file within workspace where the Red Hat Dependency Analytics report will be saved. `(default: redhat-dependency-analytics-report.json)`
- **image**: Image where Exhort Javascript API and required dependencies are installed. `(default: quay.io/ecosystem-appeng/exhort-javascript-api:0.7.0-alpha)`. 
<br />
List of images for different ecosystem versions can be found [here](https://github.com/RHEcosystemAppEng/exhort-javascript-api/tree/main/docker-image)

## Output
The complete response of Red Hat Dependency Analytics is saved in JSON format within the workspace directory under file name defined by parameter `output-file-name`. <br />
This response provides both a summary and a comprehensive report detailing all discovered vulnerabilities. <br />
The provided response may be used by a subsequent task for decision making, such as Passing or Failing a build.  

In the logs, a simplified report summary will be displayed, example:
```
Red Hat Dependency Analytics task is being executed.
==================================================
Red Hat Dependency Analytics Report
==================================================
Total Scanned Dependencies            :  10 
Total Scanned Transitive Dependencies :  218 
Total Vulnerabilities                 :  22 
Direct Vulnerable Dependencies        :  5 
Snyk Provider Status                  :  OK 
Critical Vulnerabilities              :  1 
High Vulnerabilities                  :  3 
Medium Vulnerabilities                :  12 
Low Vulnerabilities                   :  6 
==================================================
Full report is saved into file: redhat-dependency-analytics-report.json
Task is completed.
```

## Installation

### Install task on environment using kubectl
```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/redhat-dependency-analytics/0.1/redhat-dependency-analytics.yaml -n <NAMESPACE>
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
      value: /path/to/manifest/file/in/project/directory
    - name: project-directory-path
      value: /path/to/project/directory/in/workspace
    - name: output-file-path
      value: /path/to/output/file/in/workspace
    - name: image
      value: your-image-name:tag
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

1. In [secret.yaml](samples/secret.yaml), first replace `{{ EXHORT_SNYK_TOKEN }}` with a generated Snyk token, then create the secret, run:
    ```
    kubectl apply -f samples/secret.yaml -n <NAMESPACE>
    ```
    To generate a new Snyk token visit the following [link](https://app.snyk.io/login?utm_campaign=Code-Ready-Analytics-2020&utm_source=code_ready&code_ready=FF1B53D9-57BE-4613-96D7-1D06066C38C9).

1. Deploy the redhat-dependency-analytics task by utilizing the [redhat-dependency-analytics.yaml](redhat-dependency-analytics.yaml) configuration file. You can initiate it by using the following command:
    ```
    kubectl apply -f redhat-dependency-analytics.yaml -n <NAMESPACE>
    ```
    Alternatively, you can consult the [installation guidelines](#installation) for the task setup instructions.

#### For PipelineRun Example:

1. Deploy the [git-clone](https://hub.tekton.dev/tekton/task/git-clone) Tekton Task to your environment. Refer to the `git-clone` documentation for instructions on setting up the pipeline with the appropriate parameters to align with your GitHub repository.
<br >**NOTE** that the sample pipeline has been pre-configured to facilitate the cloning of public repositories in a straightforward manner. In this setup, simply providing an HTTPS URL for a public repository is adequate to ensure the functionality of the pipeline.

1. Deploy the pipeline with [pipeline.yaml](samples/pipeline.yaml), run:
    ```
    kubectl apply -f samples/pipeline.yaml -n <NAMESPACE>
    ```

1. In [pipeline-run.yaml](samples/pipeline-run.yaml), first replace `{{ GITHUB_URL }}` with the Github URL to the project repository where the target manifest file resides, next replace `{{ MANIFEST_FILE_PATH }}` with the path to the target manifest file within the project directory (e.g., "pom.xml" or "src/pom.xml"), finally create the pipelinerun, run:
    ```
    kubectl apply -f samples/pipeline-run.yaml -n <NAMESPACE>
    ```

#### For TaskRun Example:

1. Within workspace, create a new project directory (update parameter `project-directory-path` if needed).

1. Store the target manifest file into a desired location inside the project directory.

1. In [task-run.yaml](samples/task-run.yaml), replace `{{ MANIFEST_FILE_PATH }}` with the path to the target manifest file within the project directory (e.g., "pom.xml" or "src/pom.xml"), then create the taskrun, run:
    ```
    kubectl apply -f samples/task-run.yaml -n <NAMESPACE>
    ```

<small>**NOTE:** The redhat-dependency-analytics task expects to have a secret by the name of `exhort` configured with the `EXHORT_SNYK_TOKEN` key, 
as well as an attached workspace with the target manifest file stored within.</small>