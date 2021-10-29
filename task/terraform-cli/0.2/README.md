

## Terraform CLI Task

[Terraform](https://www.terraform.io/)  is an open-source infrastructure as codesoftware tool created by [HashiCorp](https://en.wikipedia.org/wiki/HashiCorp "HashiCorp"). It enables users to define and provision a datacenter infrastructure using a high-level configuration language known as Hashicorp Configuration Language (HCL), or optionally JSON

This Task will do a terraform init before it executes the actual configured ARGS from parameter.

## Install the Task

Install `terraform-cli` task:
```bash
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/task/terraform-cli/0.2/terraform-cli.yaml
```

## Parameters

* **ARGS:** args to execute which are appended to `terraform` e.g. `apply` (_default_: `--help`)
* **terraform-secret:** the name of the secret containing the authentication information for the chosen provider (_default_: `terraform-creds`) 
* **image:** the image used where the Terraform CLI binary is (_default_: `docker.io/hashicorp/terraform:light`)
* **httpProxy**: HTTP proxy server for non-SSL requests (_default_: "")
* **httpsProxy**: HTTPS proxy server for SSL requests (_default_: "")
* **noProxy**: no proxy - opt out of proxying HTTP/HTTPS requests (_default_: "")

## Workspaces

* **source**: A [Workspace](https://github.com/tektoncd/pipeline/blob/master/docs/workspaces.md) containing the terraform HCL or JSON files.


## Terraform-Secret

This is a [secret]([https://kubernetes.io/docs/concepts/configuration/secret/](https://kubernetes.io/docs/concepts/configuration/secret/)) example with Credentials information [for the openstack provider](https://www.terraform.io/docs/providers/openstack/index.html) for information on how to configure authentication on different providers please refer to this [documentation](https://www.terraform.io/docs/providers/index.html) all providers have exclusive names for the environment variables for authentication, you can create a secret that will be mounted as environment variables for the provider, or you can provide that on your provider.tf file.

```yaml
kind: Secret
apiVersion: v1
metadata:
  name: terraform-secret
  namespace: terraform-cli-test
  selfLink: /api/v1/namespaces/terraform-cli-test/secrets/terraform-secret
  uid: a015225d-0f8a-11ea-8536-52fdfc072182
  resourceVersion: '626903'
  creationTimestamp: '2019-11-25T13:51:05Z'
data:
  OS_AUTH_URL: aHR0cDovL3lvdXItY2xvdWQtcHJvZGl2ZGVyLmNvbQ==
  OS_INSECURE: dHJ1ZQ==
  OS_PASSWORD: c2VjcmV0
  OS_TENANT_NAME: bXlfdGVuYW50X25hbWU=
  OS_USERNAME: bXlfdXNlcl9uYW1l
type: Opaque
```


To create a secret you can use the following command

```bash
kubectl create secret generic terraform-secret --from-literal=TF_VAR_OS_USERNAME=my-username --from-literal=TF_VAR_OS_AUTH_URL=https://my_auth_url --from-literal=TF_VAR_OS_TENANT_NAME=my_tenant --from-literal=TF_VAR_OS_PASSWORD=my_password --from-literal=TF_VAR_OS_INSECURE=true

```

Be aware that Terraform Environment Variables have to be defined with `TF_VAR_` prefix.


## ServiceAccount

If you don't specify a service account to be used for running the `TaskRun` or `PipelineRun`, the `default` [service account](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#use-the-default-service-account-to-access-the-api-server). OpenShift by default does not allow the default service account to modify objects in the namespace. Therefore you should either explicitly grant permission to the default service account (by creating rolebindings) or [create a new service account with sufficient privileges](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#service-account-permissions) and specify it on the [`TaskRun`](https://github.com/tektoncd/pipeline/blob/master/docs/taskruns.md#service-account) or [`PipelineRun`](https://github.com/tektoncd/pipeline/blob/master/docs/pipelineruns.md#service-account).

You can do the former via `oc` and running the following command, replacing `<namespace>` with your target namespace:
```bash
oc policy add-role-to-user edit -z default -n <namespace>
```

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

This is a pipeline example passing the required credentials, and a list of arguments to the ARGS array variable.

```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: terraform-cli-example
spec:
  workspaces:
  - name: source
  tasks:
  - name: terraform
    taskRef:
      name: terraform-cli
    workspaces:
    - name: source
      workspace: source
    params:
     - name: terraform-secret
       value: "terraform-secret"
     - name: ARGS
       value:
         - apply
         - "-auto-approve"
```
