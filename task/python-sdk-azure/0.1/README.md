

---

# Tekton Task: Run Python Scripts with Azure SDK

This Tekton Task allows you to run Python scripts that interact with Azure services using the Azure SDK. It's designed to securely use Azure credentials via Kubernetes Secrets and retrieve scripts from ConfigMaps, making your pipelines clean and modular.

---

## Features

- Executes Python scripts using Azure SDK (`azure-identity`, `azure-storage-blob`, etc.)
- Securely injects Azure credentials from Kubernetes Secrets
- Loads Python scripts from ConfigMaps instead of embedding them
- Supports dynamic Azure region configuration via parameters
- Logs script output, useful for auditing and debugging

---

## Prerequisites

- A Kubernetes cluster with Tekton Pipelines installed
- An active Azure account with appropriate permissions
- A Kubernetes Secret containing Azure credentials (`AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `AZURE_TENANT_ID`)
- A ConfigMap that holds your Python script
- A basic understanding of Tekton Task and TaskRun concepts

---

## Components

### 1. Kubernetes Secret: `azure-credentials`

Stores Azure authentication details securely and is referenced by the Task to set environment variables.

### 2. ConfigMap: `python-script-configmap`

Contains the Python script that uses Azure SDK to interact with Azure resources.

### 3. Tekton Task: `python-azure-sdk`

Defines the steps to:
- Install required Azure SDK packages
- Inject credentials
- Load and execute the Python script

### 4. Tekton TaskRun: `python-azure-sdk-run`

Used to trigger the Task with optional parameters like Azure region.

---

## How It Works

- Credentials are injected into the container from the Secret.
- The script is mounted into the container from the ConfigMap.
- Required Azure SDK libraries are installed inside the Task container.
- The script is executed and the output is printed in the logs.

---

## Usage Workflow

1. Create a Kubernetes Secret with Azure credentials.
2. Create a ConfigMap containing the Python script.
3. Apply the Tekton Task that defines execution logic.
4. Trigger the Task using a TaskRun, optionally specifying the Azure region.

---

## Example Use Case

Use this setup to:

- Authenticate to Azure using `DefaultAzureCredential`
- Connect to Azure Storage
- List available containers or perform blob operations
- Print results in TaskRun logs

---

## Best Practices

- Keep your Python scripts modular and reusable via ConfigMaps
- Avoid hardcoding credentials—always use Kubernetes Secrets
- Use parameterization to control regions or other inputs
- Store logs for audit and debugging


Let me know if you want this turned into an actual GitHub repo with all the files laid out!
