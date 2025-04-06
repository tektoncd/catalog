
---

```markdown
# 🔷 Tekton Task: Run Python Scripts with Azure SDK

This Tekton Task enables execution of Python scripts that interact with Azure services using the Azure SDK. The solution is designed to promote secure credential management and modular pipeline design.

---

## ✨ Features

- ✅ Runs Python scripts using Azure SDK modules like `azure-identity`, `azure-storage-blob`, etc.
- 🔐 Securely authenticates to Azure using Kubernetes Secrets
- 🧩 Uses ConfigMaps to load dynamic Python scripts (decouples script from pipeline)
- 🌍 Supports dynamic input of Azure regions via `params`

---

## 📦 Prerequisites

Ensure you have the following before using this Task:

- A **Kubernetes cluster** with **Tekton Pipelines installed**
- An **Azure account** with necessary permissions (e.g., Reader or Contributor roles)
- A **Kubernetes Secret** containing Azure credentials:
  - `AZURE_CLIENT_ID`
  - `AZURE_CLIENT_SECRET`
  - `AZURE_TENANT_ID`
- A **Kubernetes ConfigMap** containing the Python script you want to execute

---

## 🧱 Architecture Overview

```text
+---------------------------+
|     Tekton TaskRun       |
|--------------------------|
|  Inject Azure Credentials|
|  Load Script from ConfigMap |
|  Install Azure SDKs      |
|  Run Python Script       |
+---------------------------+
```

---

## 🔐 Step 1: Create Azure Credentials Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: azure-credentials
type: Opaque
stringData:
  AZURE_CLIENT_ID: "<your-client-id>"
  AZURE_CLIENT_SECRET: "<your-client-secret>"
  AZURE_TENANT_ID: "<your-tenant-id>"
```

Apply with:

```bash
kubectl apply -f azure-secret.yaml
```

---

## 📝 Step 2: Create Python Script ConfigMap

Save your Python script (e.g., `list_containers.py`) locally:

```python
# list_containers.py
from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient

credential = DefaultAzureCredential()
account_url = "https://<your-storage-account>.blob.core.windows.net"
service_client = BlobServiceClient(account_url=account_url, credential=credential)

print("Containers:")
for container in service_client.list_containers():
    print(f"- {container['name']}")
```

Create the ConfigMap:

```bash
kubectl create configmap python-script-configmap --from-file=list_containers.py
```

---

## 📋 Step 3: Define the Tekton Task

```yaml
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: python-azure-sdk
spec:
  params:
    - name: region
      type: string
      default: eastus
  steps:
    - name: run-python
      image: python:3.11
      env:
        - name: AZURE_CLIENT_ID
          valueFrom:
            secretKeyRef:
              name: azure-credentials
              key: AZURE_CLIENT_ID
        - name: AZURE_CLIENT_SECRET
          valueFrom:
            secretKeyRef:
              name: azure-credentials
              key: AZURE_CLIENT_SECRET
        - name: AZURE_TENANT_ID
          valueFrom:
            secretKeyRef:
              name: azure-credentials
              key: AZURE_TENANT_ID
      volumeMounts:
        - name: script-volume
          mountPath: /scripts
      workingDir: /scripts
      script: |
        pip install azure-identity azure-storage-blob
        python list_containers.py
  volumes:
    - name: script-volume
      configMap:
        name: python-script-configmap
```

Apply with:

```bash
kubectl apply -f task-python-azure-sdk.yaml
```

---

## 🚀 Step 4: Run the Task with TaskRun

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: python-azure-sdk-run
spec:
  taskRef:
    name: python-azure-sdk
  params:
    - name: region
      value: eastus
```

Apply with:

```bash
kubectl apply -f taskrun-python-azure-sdk.yaml
```

---

## 🔍 Example Output

```bash
Containers:
- logs-container
- backup-data
- reports2024
```

---

## 🛡️ Security Note

- Credentials are injected using environment variables from Kubernetes Secrets
- No sensitive data is hard-coded or stored in the script/configmap

---

## 💡 Use Cases

- Automate Azure resource audits
- Run scheduled data processing jobs
- Fetch metadata from Azure Storage, Key Vault, etc.
- Teach CI/CD with Azure using Tekton and Kubernetes

---

## 📂 Repository Structure Suggestion

```
.
├── azure-secret.yaml
├── configmap-script.yaml
├── list_containers.py
├── task-python-azure-sdk.yaml
└── taskrun-python-azure-sdk.yaml
```

---

## 🙌 Contributions

Feel free to fork this repo, submit pull requests, or share issues you encounter!

---
