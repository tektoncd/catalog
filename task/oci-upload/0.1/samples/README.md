# OCI Upload Task Examples

**SECURITY WARNING**: These examples contain placeholder credentials. **NEVER** commit real OCI credentials to version control.

## Files

- **`secret-template.yaml`** - Template for creating OCI credentials secret
- **`taskrun-example.yaml`** - Two TaskRun examples: one with sample data creation, one simple
- **`pipeline-example.yaml`** - Pipeline integration example

## Required Parameters

**Replace these placeholder values with actual OCI details:**

- `tenancyOcid`: OCI tenancy OCID
- `userOcid`: OCI user OCID  
- `region`: OCI region (e.g., `us-ashburn-1`)
- `namespace`: OCI Object Storage namespace
- `bucketName`: Target bucket name

## Quick Start

### 1. Create OCI Credentials Secret

```bash
# Edit secret-template.yaml with your real credentials
kubectl apply -f secret-template.yaml
```

### 2. Run the Examples

```bash
# Run the complete example with sample data creation
kubectl apply -f taskrun-example.yaml

# Check status
kubectl get taskrun oci-upload-with-sample-files
kubectl get taskrun oci-upload-simple
```

## TaskRun Examples

### First Example: `oci-upload-with-sample-files`
- Creates sample files automatically
- Uses volumeClaimTemplate for storage
- Complete self-contained test

### Second Example: `oci-upload-simple`
- Uses the oci-upload task directly
- Uses emptyDir workspace
- Requires you to populate workspace beforehand

## PipelineRun Example: `pipeline-example.yaml`
- Shows how to use oci-upload in a pipeline
- Includes data preparation and upload tasks
- Uses volumeClaimTemplate for shared workspace

### Running the Pipeline

```bash
# Apply the pipeline and run it
kubectl apply -f pipeline-example.yaml

# Check pipeline status
kubectl get pipelinerun oci-upload-pipeline-run
```

## Path Options

- `path: "."` - Upload all files from workspace root
- `path: "sample-data/"` - Upload specific directory
- `path: "file.jar"` - Upload single file

## Security

- Store credentials in Kubernetes secrets only
- Never commit real credentials to git
- Use least privilege OCI IAM policies
