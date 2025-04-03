**Tekton Task for Running Python Scripts with Azure SDK**

This Tekton Task enables execution of Python scripts that utilize the Azure SDK to interact with Azure services. The Task is designed to securely authenticate using Azure credentials and execute the script from a ConfigMap without embedding the script directly in the pipeline.


**Features**

Runs Python scripts with Azure SDK support  
Uses Azure credentials securely via a Kubernetes Secret  
Retrieves the script from a ConfigMap to keep pipelines modular  
Allows specifying the Azure region dynamically  



**Prerequisites**

Before running the Task, ensure you have:  

A Kubernetes cluster with Tekton installed  
An Azure account with appropriate permissions  
A Kubernetes Secret for Azure credentials  
A ConfigMap containing the Python script  



Components

This setup consists of the following:  

Kubernetes Secret: `azure-credentials`  
Stores Azure authentication details, including:  

- AZURE_CLIENT_ID  
- AZURE_CLIENT_SECRET  
- AZURE_TENANT_ID  

ConfigMap: python-script-configmap
Holds the Python script to be executed.  

Tekton Task: python-azure-sdk  
Defines the steps to install required Azure SDK libraries and execute the script.  

Tekton TaskRun: python-azure-sdk-run 
Triggers the Task execution.  



How It Works

Azure credentials** are injected from the Kubernetes Secret.  
Python script is retrieved from the ConfigMap and mounted inside the container.  
Required dependencies (`azure-identity`, `azure-storage-blob`, etc.) are installed.  
The script is executed with azure authentication.  
Results (such as listing Azure Storage containers) are printed in the logs.  

---

Steps to Use  

Step 1: Create the Azure Credentials Secret 
Store your Azure authentication details in a Kubernetes Secret to be used by the pipeline.  

Step 2: Create a ConfigMap for the Python Script 
Prepare a ConfigMap with the Python script that interacts with Azure.  

Step 3: Apply the Tekton Task  
Deploy the Tekton Task to your cluster.  

Step 4: Run the Task using TaskRun 
Execute the Task with dynamic parameters (such as Azure region).  

---

 Example Use Case  

A typical scenario would be:  

Authenticating to Azure** using DefaultAzureCredential
Connecting to Azure Storage 
Listing available Storage Containers  
Printing the output to logs  


 

This Tekton Task provides a secure, scalable, and reusable approach to running Python scripts that interact with Azure services. By leveraging ConfigMaps and Secrets, it ensures that sensitive credentials are protected while maintaining modularity in pipeline execution.  
