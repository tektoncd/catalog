
## Ansible Tower CLI Task

[Ansible Tower](https://ansible.com/tower) (formerly ‘AWX’) is a web-based solution that makes Ansible even more easy to use for IT teams of all kinds, It provides the `tower-cli`([Tower-CLI]([https://docs.ansible.com/ansible-tower/latest/html/towerapi/tower_cli.html](https://docs.ansible.com/ansible-tower/latest/html/towerapi/tower_cli.html))) command line tool that simplifies the tasks of starting jobs, workflow jobs, manage users, projects etc.

## Install the Task

Install `tower-cli` task:
```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/ansible-tower-cli/ansible-tower-cli-task.yaml
```

## Inputs `tower-cli-task`

### Parameters

* **ARGS:** args to execute which are appended to `tower-cli` e.g. `user-list` (_default_: `--help`)
* **SSLVERIFY:** args to disable Tower SSL verification (_default_: `false`)
* **HOST:** The Ansible Tower HOST
* **tower-secret:** the name of the secret containing the user and password for authentication on the ansible tower host (_default_: `tower-creds`)

## Tower-Secret

This is a [secret]([https://kubernetes.io/docs/concepts/configuration/secret/](https://kubernetes.io/docs/concepts/configuration/secret/)) example with USER and PASS information that are going to be used by the task

```yaml
kind: Secret
apiVersion: v1
metadata:
   name: tower-creds
   namespace: ansible-tower-pipelines-test
   selfLink: /api/v1/namespaces/ansible-tower-pipelines-test/secrets/tower-creds
   uid: 024681c0-f4e8-11e9-81e2-52fdfc072182
   resourceVersion: '721636'
   creationTimestamp: '2019-10-22T16:21:31Z'
data:
   PASS: YWRtaW50b3dlcg==
   USER: YWRtaW4=
type: Opaque
```


To create a secret you can use the following command

```
kubectl create secret generic tower-creds --from-literal=username=TOWER_USER --from-literal=password=TOWER_USER_PASSWORD
```

## ServiceAccount

If you don't specify a service account to be used for running the `TaskRun` or `PipelineRun`, the `default` [service account](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#use-the-default-service-account-to-access-the-api-server). OpenShift by default does not allow the default service account to modify objects in the namespace. Therefore you should either explicitly grant permission to the default service account (by creating rolebindings) or [create a new service account with sufficient privileges](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#service-account-permissions) and specify it on the [`TaskRun`](https://github.com/tektoncd/pipeline/blob/master/docs/taskruns.md#service-account) or [`PipelineRun`](https://github.com/tektoncd/pipeline/blob/master/docs/pipelineruns.md#service-account).

You can do the former via `oc` and running the following command, replacing `<namespace>` with your target namespace:
```
oc policy add-role-to-user edit -z default -n <namespace>
```

## Usage

This is a pipeline example passing the required credentials, and a list of arguments to the ARGS array variable.

```yaml
apiVersion: tekton.dev/v1alpha1
kind: Pipeline
metadata:
  name: tower-cli-example
spec:
  tasks:
  - name: tower
    taskRef: 
      name: ansible-tower-cli
    params:
     - name: SSLVERIFY
       value: "false"
     - name: HOST
       value: "10.8.109.202"
     - name: tower-secret
       value: "tower-creds"
     - name: ARGS
       value:
         - user
         - list

```
