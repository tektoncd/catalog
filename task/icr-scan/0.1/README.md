# Intelligent Code Repair(iCR)

Intelligent Code Repair(iCR) is a code analysis tool that performs static analysis on Java and Python source codes. It detects critical security vulnerabilties across software codebases suggests appropriate fix for those.

The following task initiates a static analysis for the named source code which is fetched from a GitHub repository. The results including detected errors and synthesized corrections are sent to a named server. 

## Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/icr-scan/0.1/raw
```

## Pre-requisite

Install the `git-clone` task from the catalog

```
https://api.hub.tekton.dev/v1/resource/tekton/task/git-clone/0.7/raw
```

## Parameters

- **iCR-License**: The license, to be obtained from OpenRefactory, which is required to use iCR toscan a source code repository.
- **Git-Revision**: The branch of the repository on which ICR  is to perform the code analysis. If a branch is not specified, it will default to “master”.
- **Server-URL**: The URL of the server where the results will be sent
- **iCR-Username**: The Username for iCR. Default is admin
- **iCR-Password**: The password for iCR. Default is admin


## Workspaces

- **source**: `PersistentVolumeClaim`-type so that volume can be shared among git-clone and icr-scan task. Sample PVC can be found [here](../0.1/tests/resources.yaml)