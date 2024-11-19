Running OCI CLI Commands with Tekton Task
This guide explains how to use a Tekton Task and TaskRun to execute OCI (Oracle Cloud Infrastructure) CLI commands using the ghcr.io/oracle/oci-cli:latest Docker image.



       Prerequisites
Before proceeding, ensure you have the following:

A Kubernetes cluster with Tekton Pipelines installed.
Access to OCI with:
Tenancy OCID: Found in the OCI Console under Administration > Tenancy Details.
User OCID: Found in Identity > Users.
API Key Fingerprint: Found in your API key details.
Private Key: The key you use for OCI API authentication.
Region: The OCI region identifier (e.g., us-ashburn-1).


       Encode Your Private Key
The private key must be base64 encoded before use.

Run the following command to encode your private key:

cat ~/.oci/oci_api_key.pem | base64


Save the output for use in the TaskRun


Apply the Tekton Task
Save the following Tekton Task YAML as oci-cli-task.yaml


Execute the Task with TaskRun
Save the following TaskRun YAML as oci-cli-taskrun.yaml

Replace placeholders in the TaskRun:

<YOUR_TENANCY_OCID>: Your Tenancy OCID.
<YOUR_USER_OCID>: Your User OCID.
<YOUR_FINGERPRINT>: Your API key fingerprint.
<BASE64_ENCODED_PRIVATE_KEY>: The base64-encoded private key content.


