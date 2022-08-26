# Canary Release using Istio

The following task can be used to do canary deployment by doing a canary traffic routing to the deployed versions.

When the new version of application is deployed, you can start routing a few selected users to it. As you gain more confidence in the new version, you can start releasing it to more servers in your infrastructure and routing more users to it.

For more details about canary release please refer [here](https://martinfowler.com/bliki/CanaryRelease.html)

### **PRE-REQUISITE**: Istio should already be installed in the same cluster.

## Installing the tasks

1. For Application Manifests deployment we can use the existing `kubenetes-actions` task from the catalog

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/kubernetes-actions/0.1/raw
```

2. For Istio Services

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/istio-canary-release/0.1/raw
```

## Installing the ClusterRoleBinding

```bash
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/istio-canary-release/0.1/support/clusterrolebinding.yaml
```

## Workspaces

- **deployment-manifest-dir**: The workspace in which `ConfigMap` containing all the deployment manifests will be mounted.
- **istio-manifest-dir**: The workspace in which `ConfigMap` containing the istio related manifests will be mounted.

## Params for Canary-Istio-Deploy

- **VS_NAME**: The name of the `VirtualService`
- **V1_WEIGHT**: The traffic weight to be diverted to existing version v1
- **V2_WEIGHT**: The traffic weight to be diverted to new version v2

**Note**: The above parameters are used in case we need to do traffic splitting using virtual service and for creating a `VirtualService` then use the `ConfigMap` as shown below.

## Platforms

The Task can be run on `linux/amd64` platform.

# Usage

1. Create `ConfigMap` for `Istio` manifests

```bash
kubectl create configmap istio --from-file="./samples/application/app-gateway.yaml"
```

2. Create `ConfigMap` for `Deployment` manifests

```bash
kubectl create configmap deployment --from-file="isto-canary-release/samples/application/myapp.yaml"
```

In case of app deployment and configuring Istio follow [this](./samples/run.yaml) example.

In case of just re-configuring the Istio follow [this](./samples/taskrun.yaml) example.
