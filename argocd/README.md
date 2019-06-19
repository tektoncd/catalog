# Argo CD

This task syncs an Argo CD application and waits for it to be healthy. To do so, it requires the address of the Argo CD server and some form of authentication - either a username/password or an authentication token.

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/argocd/argocd.yaml
```

## Inputs

### Parameters

* **server:** Argo CD server address

* **username:** Login username (_default:_ admin)

* **password:** Login password (_default:_ admin)

* **token:** Login token, used in place of username/password if default is overridden (_default:_ none)

* **application-name:** Name of the application to sync

* **revision:** The revision to sync to

* **flags:** Flags to append after commands, e.g. `--insecure` (_default:_ `--`)

## Usage

This Pipeline runs a sample Task that makes and pushes a change to a Git repository, after which it runs the Argo CD task to sync an application based on that repository.

```YAML
apiVersion: tekton.dev/v1alpha1
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
        - name: server
          value: argocd-server.argocd.svc.cluster.local
        - name: application-name
          value: some-application
        - name: username
          value: admin
        - name: password
          value: password123
        - name: flags
          value: --insecure # needed in this example only because the Argo CD server is locally hosted
```

Note that 

```YAML
- name: username
  value: admin
- name: password
  value: password123
```

can be replaced with

``` YAML
- name: token
  value: some-token
```

as another way to log in.