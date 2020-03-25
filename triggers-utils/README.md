# Triggers Utility Tasks

## Create Ingress

The ingress routes webhook events to the event listener service.  This task creates an ingress for any services including the event listener service

## Install the create ingress task
```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/triggers-utiles/create-ingress.yaml
```
## Inputs

### Parameters

* **CreateCertificate**: Enables/disables the creation of a self-signed certificate for **ExternalDomain**.  The default is "true"
* **CertificateKeyPassphrase**: Phrase that protects private key. This must be provided when the self-signed certificate is created
* **CertificateSecretName**: Secret name for Ingress certificate. The Secret should not exist if the self-signed certificate creation is enabled
* **ExternalDomain**: The external domain for the EventListener e.g. `EventListenerName.PROXYIP.nip.io`
* **Service**: The name of the Service used in the Ingress. This will also be the name of the Ingress
* **ServicePort**: The service port that the ingress is being created on
* **ServiceUID**: The uid of the service. If set, this creates an owner reference on the service. The default is  "".


## Usage

This TaskRun creates the ingress for the given service.

```
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: create-ingress-run
spec:
  taskRef:
    name: create-ingress
  params:
  - name: CreateCertificate
    value: "true"
  - name: CertificateKeyPassphrase
    value: asecretphrase
  - name: CertificateSecretName
    value: ingresssecret
  - name: ExternalDomain
    value: tekton.io
  - name: Service
    value: el-demo-listener
  - name: ServicePort
      value: "8080"
  timeout: 1000s
  serviceAccountName: tekton-triggers-createwebhook
```


## Create Webhook

The webhook sends events to the event listener service.  This task creates a webhook in github repository.

## Install the create webhook task
```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/triggers-utiles/create-webhook.yaml
```
## Inputs

### Parameters

* **ExternalDomain**: The external domain for the EventListener e.g. `EventListenerName.<PROXYIP>.nip.io`
* **GitHubUser**: The GitHub user
* **GitHubRepo**: The GitHub repo where the webhook will be created
* **GitHubOrg**: The GitHub organization where the webhook will be created
* **GitHubSecretName**: The Secret name for GitHub access token. This is always mounted and must exist
* **GitHubAccessTokenKey**: The GitHub access token key name
* **GitHubSecretStringKey**: The GitHub secret string key name
* **GitHubDomain**: The GitHub domain. Override for GitHub Enterprise. The default is "github.com"
* **WebhookEvents**: List of events the webhook will send notifications for. The default is '[\"push\",\"pull_request\"]'

## Usage

You will need to create a
[GitHub Personal Access Token](https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line#creating-a-token)
with the following access.

- `public_repo`
- `admin:repo_hook`

Next, create a secret like so with your access token.

```
apiVersion: v1
kind: Secret
metadata:
  name: webhook-secret
stringData:
  token: YOUR-GITHUB-PERSONAL-ACCESS-TOKEN
  secret: random-string-data
```

### Taskrun

This TaskRun creates the webhook in the github repository.

There are a few fields to change, but these fields must be updated at the
minimum.

- GitHubOrg 
- GitHubUser 
- GitHubRepo 

```
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: create-webhook-run
spec:
  taskRef:
    name: create-webhook
  params:
  - name: GitHubOrg
    value: "tektoncd"
  - name: GitHubUser
    value: "tekton-user"
  - name: GitHubRepo
    value: "catalog"
  - name: GitHubSecretName
    value: webhook-secret
  - name: GitHubAccessTokenKey
    value: token
  - name: GitHubSecretStringKey
    value: secret
  - name: ExternalDomain
    value: demo.tekton.io
  timeout: 1000s
  serviceAccountName: tekton-triggers-createwebhook

```