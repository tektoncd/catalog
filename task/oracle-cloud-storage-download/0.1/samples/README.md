# Oracle Cloud Storage Download - Samples

This directory contains sample configurations for using the `oracle-cloud-storage-download` task.

## Files

### secret-template.yaml
Template for creating an OCI credentials secret. Contains all the necessary fields for OCI authentication.

**Important**: Do not commit actual credentials to version control!

### taskrun-example.yaml
Basic example of a TaskRun that downloads a directory from OCI Object Storage.

### taskrun-single-file.yaml
Example of downloading a single file from OCI Object Storage.

### pipeline-download-directory.yaml
Complete pipeline example that:
1. Downloads files from OCI Object Storage
2. Lists the downloaded files

This example shows how to use the task in a pipeline context, similar to the GCS download pattern.

## Quick Start

1. Create the OCI credentials secret:
   ```bash
   kubectl apply -f secret-template.yaml
   # Remember to edit it with your actual credentials first!
   ```

2. Apply the task definition:
   ```bash
   kubectl apply -f ../oracle-cloud-storage-download.yaml
   ```

3. Run one of the examples:
   ```bash
   # Directory download
   kubectl create -f taskrun-example.yaml
   
   # Single file download
   kubectl create -f taskrun-single-file.yaml
   
   # Complete pipeline
   kubectl create -f pipeline-download-directory.yaml
   ```

## Testing

To test with your own bucket:

1. Set up OCI credentials in a secret
2. Edit the bucket name and object prefix in the examples
3. Run the TaskRun:
   ```bash
   kubectl create -f taskrun-example.yaml
   ```
4. Check the logs:
   ```bash
   kubectl logs -f $(kubectl get taskrun oracle-cloud-storage-download-example -o jsonpath='{.status.podName}')
   ``