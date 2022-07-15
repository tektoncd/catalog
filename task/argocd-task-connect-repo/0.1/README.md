# ArgoCD

    This task connects a repository to Argo CD. To do so, it requires the address of the Argo CD server and some form of authentication either a username/password or an authentication token, as well as the desired repo.

## Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/argocd-task-connect-repo/0.1/raw
```

## Parameters

* **repository-url:** Name of the application to sync e.g. `https://charts.bitnami.com/bitnami`

* **repository-name:** The name you want to give to the repo, e.g. `bitnami`

* **flags:** Flags to append after commands, e.g. `--insecure` (_default:_ `--`)

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage 

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-env-configmap
  namespace: argocd
data:
  ARGOCD_SERVER: <Argo CD server address>
---
apiVersion: v1
kind: Secret
metadata:
  name: argocd-env-secret
  namespace: argocd
data:
  # choose one of username/password or auth token
  ARGOCD_USERNAME: <username>
  ARGOCD_PASSWORD: <password>
  ARGOCD_AUTH_TOKEN: <token>
---
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: argocd-pipeline-test
  namespace: argocd
spec:
  tasks:
    - name: connect-repo
      taskRef:
        name: argocd-task-connect-repo
      params:
        - name: repository-url
          value: https://charts.bitnami.com/bitnami
        - name: repository-type
          value: helm
        - name: repository-name
          value: concourse
        - name: flags
          value: --insecure
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