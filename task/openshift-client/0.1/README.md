## OpenShift Client Task

[OpenShift](http://www.openshift.com) is a Kubernetes distribution from Red Hat which provides `oc`, the [OpenShift CLI](https://docs.openshift.com/container-platform/4.1/cli_reference/getting-started-cli.html) that complements `kubectl` for simplifying deployment and configuration applications on OpenShift.

Openshift-client runs commands against the cluster where the task run is being executed


## Install the Task
```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/openshift-client/0.1/raw
```

## Parameters

* **ARGS:** args to execute which are appended to `oc` e.g. `start-build myapp` (_default_: `help`)

* **SCRIPT:** script of oc commands to execute  e.g. `oc get pod $1 -0 yaml` This will take the first value of ARGS as pod name (_default_: `oc $@`)

* **VERSION:** The OpenShift version to use (_default_: `4.6`)

## Resources

### Inputs

* **source**: a `git`-type `PipelineResource` which holds the files that needs to be applied on the cluster. (_Optional_)

## ServiceAccount

If you don't specify a service account to be used for running the `TaskRun` or `PipelineRun`, the `default` [service account](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#use-the-default-service-account-to-access-the-api-server). OpenShift by default does not allow the default service account to modify objects in the namespace. Therefore you should either explicitly grant permission to the default service account (by creating rolebindings) or [create a new service account with sufficient privileges](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#service-account-permissions) and specify it on the [`TaskRun`](https://github.com/tektoncd/pipeline/blob/main/docs/taskruns.md#service-account) or [`PipelineRun`](https://github.com/tektoncd/pipeline/blob/main/docs/pipelineruns.md#service-account).

You can do the former via `oc` and running the following command, replacing `<namespace>` with your target namespace:
```
oc policy add-role-to-user edit -z default -n <namespace>
```

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

This `TaskRun` runs an `oc rollout` command to deploy the latest image version for `myapp` on OpenShift.

```
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: deploy-myapp
spec:
  taskRef:
    name: openshift-client
  params:
  - name: ARGS
    value:
      - "rollout"
      - "latest"
      - "myapp"
```
