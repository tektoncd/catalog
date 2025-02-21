
# **Python Azure SDK Task**

This Tekton Task defines a reusable Task named `python-azure` for running Python scripts that use the Azure SDK to interact with Azure services.

## **Parameters**

The Task accepts the following parameters:

- **`azure-region`** (optional, default: `eastus`): The Azure region to use for the Azure client.

## **Volumes**

The Task expects a ConfigMap named `python-script-configmap` to be mounted as a volume named `python-script`. This ConfigMap should contain the Python script to be executed, with the key `script.py`.

## **Steps**

The Task consists of a single step that runs the Python script using the `python:3.9` image. The step performs the following actions:

1. Installs the `azure-identity` and `azure-mgmt` libraries using `pip`.
2. Sets the Azure credentials (`AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, and `AZURE_CLIENT_SECRET`) as environment variables from a Kubernetes Secret named `azure-credentials`.
3. Sets the Azure region (`AZURE_REGION`) as an environment variable, using the value provided in the `azure-region` parameter.
4. Mounts the `python-script` volume containing the Python script at `/workspace/python-script`.
5. Executes the Python script located at `/workspace/python-script/script.py`.

## **Usage**

### 1. **Create Azure Credentials Secret**

You'll need to create a Kubernetes Secret named `azure-credentials` that contains your Azure service principal credentials (client ID, client secret, and tenant ID).

Here is an example of how to create the secret:

```bash
kubectl create secret generic azure-credentials \
  --from-literal=client-id=<your-client-id> \
  --from-literal=client-secret=<your-client-secret> \
  --from-literal=tenant-id=<your-tenant-id>
```

### 2. **Create ConfigMap with Python Script**

The Task expects a ConfigMap named `python-script-configmap` to contain the Python script (`script.py`). You can create this ConfigMap with the following command:

```bash
kubectl create configmap python-script-configmap --from-file=script.py
```

The `script.py` can be any Python script that uses the Azure SDK to interact with Azure resources. Here’s an example `script.py` that lists all resource groups in your Azure subscription:

#### Example Python Script (`script.py`):

```python
from azure.identity import ClientSecretCredential
from azure.mgmt.resource import ResourceManagementClient

# Azure credentials
tenant_id = "<your-tenant-id>"
client_id = "<your-client-id>"
client_secret = "<your-client-secret>"

# Authenticate using the service principal
credential = ClientSecretCredential(tenant_id, client_id, client_secret)

# Create a resource management client
resource_client = ResourceManagementClient(credential, "<your-subscription-id>")

# List all resource groups in the subscription
resource_groups = resource_client.resource_groups.list()

# Print resource group names
for rg in resource_groups:
    print(f"Resource Group: {rg.name}")
```

### 3. **Tekton Task**

This Tekton Task will run the script using the provided credentials and region information.

```yaml
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: python-azure
  labels:
    app.kubernetes.io/version: "0.1"
  annotations:
    tekton.dev/pipelines.minVersion: "0.54.0"
    tekton.dev/categories: sdk
    tekton.dev/tags: CLI, azure, sdk
    tekton.dev/displayName: "python azure sdk"
    tekton.dev/platforms: "linux/amd64"
spec:
  params:
    - name: azure-region
      type: string
      default: "eastus"
      description: Azure region
  volumes:
    - name: python-script
      configMap:
        name: python-script-configmap
  steps:
    - name: run-python-script
      image: docker.io/library/python:3.9.19-alpine3.20@sha256:45cc18540209d878c2b24080cf8f64fc37603721b67d0ecc508799e2f9a9b21d
      env:
        - name: AZURE_CLIENT_ID
          valueFrom:
            secretKeyRef:
              name: azure-credentials
              key: client-id
        - name: AZURE_TENANT_ID
          valueFrom:
            secretKeyRef:
              name: azure-credentials
              key: tenant-id
        - name: AZURE_CLIENT_SECRET
          valueFrom:
            secretKeyRef:
              name: azure-credentials
              key: client-secret
        - name: AZURE_REGION
          value: $(params.azure-region)
      volumeMounts:
        - name: python-script
          mountPath: /workspace/python-script
      script: |
        pip install azure-identity azure-mgmt
        python /workspace/python-script/script.py
```

### 4. **Tekton TaskRun**

Now, you can create a TaskRun to trigger the execution of the task. Here's an example TaskRun:

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: python-azure-taskrun
spec:
  taskRef:
    name: python-azure
  params:
    - name: azure-region
      value: "eastus"
  workspaces:
    - name: python-script
      configMap:
        name: python-script-configmap
```

### Summary

To summarize, you need to:

1. **Create a Kubernetes Secret** (`azure-credentials`) with your Azure service principal details.
2. **Create a ConfigMap** (`python-script-configmap`) containing your Python script.
3. **Create and execute a Tekton TaskRun** to run the script using the Azure SDK.

Let me know if you need further clarification or help setting this up!