# Argo CD

This task syncs (deploys) an [Argo CD](https://argoproj.github.io/argo-cd/) application and waits for it to be healthy. To do so, it requires the address of the Argo CD server and some form of authentication - either a username/password or an authentication token.

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/argocd/argocd.yaml
```

## Parameters

* **application-name:** Name of the application to sync

* **revision:** The revision to sync to (_default:_ `HEAD`)

* **flags:** Flags to append after commands, e.g. `--insecure` (_default:_ `--`)

## Usage

This `Pipeline` implements the typical CD flow using GitOps, as explained [here](https://argoproj.github.io/argo-cd/user-guide/ci_automation/). It runs a sample `Task` that makes and pushes a change to a Git repository, after which it runs the Argo CD `Task` to sync an application based on that repository.

The `ConfigMap` and `Secret` give an example of how to define the Argo CD server address and give credentials for logging in.

```YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-env-configmap
data:
  ARGOCD_SERVER: <Argo CD server address>
---
apiVersion: v1
kind: Secret
metadata:
  name: argocd-env-secret
data:
  # choose one of username/password or auth token
  ARGOCD_USERNAME: <username>
  ARGOCD_PASSWORD: <password>
  ARGOCD_AUTH_TOKEN: <token>
---
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: argocd-pipeline
spec:
  tasks:
    - name: push-to-git
      taskRef:
        name: some-git-task # pushes to the Git repository used by the application in the next task
    - name: sync-application
      taskRef:
        name: argocd-task-sync-and-wait
      params:
        - name: application-name
          value: some-application
        - name: flags
          value: --insecure # needed in this example only because the Argo CD server is locally hosted
```

For the `Secret`, choose one of username/password or auth token for logging in. Either of the following are acceptable:

```YAML
data:
  ARGOCD_USERNAME: <username>
  ARGOCD_PASSWORD: <password>
```

```YAML
data:
  ARGOCD_AUTH_TOKEN: <token>
```
