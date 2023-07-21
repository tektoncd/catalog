# Blue Green Deploy on Kubernetes

The following task can help you to deploy an application using the Blue-Green deployment strategy. This task gives you the flexibility to deploy a version of the application from the blue zone to the green zone without disturbing the previous version in the blue zone. It works by making the service point to the newer version of the application deployed.

- If you are deploying the first version of the application then it will go into the blue zone and for that you need to provide deployment and service manifests via the `workspaces` and in the `params` the service name and version. Sample Kubernetes manifests for version v1 can be found [here](./samples/v1-deploy).
- For further new deployments, it will get deployed in the other zone and then the current service will now point to the new deployment. For example if we have a deployment running in the blue zone then we will deploy the next deployment in the green zone and make the service point to the green zone or vice versa.

## Installing the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/blue-green-deploy/0.2/raw
```

## Installing the ClusterRoleBinding

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/blue-green-deploy/0.2/support/clusterrolebinding.yaml
```

## Optional Workspaces

- **manifest-dir**: Manifest files can be provided via the workspaces
- **kubeconfig-dir**: If you want to deploy you application to another cluster then you can mount your `kubeconfig` file via this `workspace`

## Parameters

- **SERVICE_NAME**: The service name pointing to the existing deployment. (_Note_: The service name for the new deployment should be same)
- **NEW_VERSION**: The version of the deployment to be deployed in the green/blue zone
- **MANIFEST**: The deployment manifest URL file path provided in case the manifest is present on Github. (_Example_: "https://raw.githubusercontent.com/tektoncd/catalog/main/task/blue-green-deploy/0.2/samples/v1-deploy/blue-deployment.yaml")
- **NAMESPACE**: Target namespace in which operation needs to be performed
- **IMAGE**: Image which has kubectl binary present (_Default_: `quay.io/openshift/origin-cli:4.9`)

## Platforms

The Task can be run on `linux/amd64` platform.

# Usage

This TaskRun runs the Task to deploy the given Kubernetes resource in the green/blue zone and toggle the service to point to the new zone.

## Without using ConfigMap

TaskRun :-

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: blue-green-deploy-run
spec:
  taskRef:
    name: blue-green-deploy-k8s
  params:
    - name: SERVICE_NAME
      value: myapp
    - name: NEW_VERSION
      value: v2
    - name: MANIFEST
      value: "https://raw.githubusercontent.com/tektoncd/catalog/main/task/blue-green-deploy/0.2/samples/v2-deploy/green-deployment.yaml"
```

## Using ConfigMap

1. Create the `ConfigMap`

```bash
kubectl create configmap manifests --from-file="green-deployment.yaml"
```

2. TaskRun:-

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: blue-green-deploy-run
spec:
  taskRef:
    name: blue-green-deploy-k8s
  params:
    - name: SERVICE_NAME
      value: myapp
    - name: NEW_VERSION
      value: v2
  workspaces:
    - name: manifest-dir
      configMap:
        name: manifests
```
