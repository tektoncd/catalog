## Openshift Client Kubecfg Task

[OpenShift](http://www.openshift.com) is a Kubernetes distribution from Red Hat which provides `oc`, the [OpenShift CLI](https://docs.openshift.com/container-platform/4.1/cli_reference/getting-started-cli.html) that complements `kubectl` for simplifying deployment and configuration applications on OpenShift.

Openshift-client-kubecfg runs commands against any cluster that is provided to it as an input

## Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/openshift-client-kubecfg/0.1/raw
```


## Parameters

* **ARGS:** args to execute which are appended to `oc` e.g. `start-build myapp` (_default_: `help`)

* **SCRIPT:** script of oc commands to execute  e.g. `oc get pod $1 -o yaml` This will take the first value of ARGS as pod name (_default_: `oc $@`)

## Resources

### Inputs

* **cluster**: a `cluster`-type `PipelineResource` specifying the target OpenShift cluster to execute the commands against it

## ServiceAccount

If you don't specify a service account to be used for running the `TaskRun` or `PipelineRun`, the `default` [service account](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#use-the-default-service-account-to-access-the-api-server). OpenShift by default does not allow the default service account to modify objects in the namespace. Therefore you should either explicitly grant permission to the default service account (by creating rolebindings) or [create a new service account with sufficient privileges](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#service-account-permissions) and specify it on the [`TaskRun`](https://github.com/tektoncd/pipeline/blob/main/docs/taskruns.md#service-account) or [`PipelineRun`](https://github.com/tektoncd/pipeline/blob/main/docs/pipelineruns.md#service-account).

You can do the former via `oc` and running the following command, replacing `<namespace>` with your target namespace:
```
oc policy add-role-to-user edit -z default -n <namespace>
```

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

The following `TaskRun` runs the commands against a different cluster than the one the `TaskRun` is running on. The cluster credentials are provided via a `PipelineResource` called `stage-cluster`.

```
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: deploy-myapp-stage
spec:
  taskRef:
    name: openshift-client-kubecfg
  resources:
    inputs:
    - name: cluster
      resourceRef:
        name: stage-cluster
  params:
  - name: ARGS
    value:
      - "rollout"
      - "latest"
      - "myapp"
```
