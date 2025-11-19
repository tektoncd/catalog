# Oracle Cloud Storage Upload - Examples

This directory contains examples demonstrating how to use the `oracle-cloud-storage-upload` task.

## Files

- **`taskrun-example.yaml`** - Four TaskRun examples with different configurations:
  - `oracle-cloud-storage-upload-simple` - Basic upload with parameters
  - `oracle-cloud-storage-upload-with-secret-config` - Upload using complete secret
  - `oracle-cloud-storage-sync` - Upload with sync (deleteExtraFiles)
  - `oracle-cloud-storage-upload-with-extraargs` - Advanced upload with metadata
- **`pipeline-upload-single-file.yaml`** - Pipeline for single file upload
  - Pipeline: `upload-to-oci-pipeline`
  - PipelineRun: `upload-to-oci-pipeline-run-no-prompt`
- **`pipeline-upload-directory.yaml`** - Pipeline for directory upload
  - Pipeline: `upload-directory-to-oci-pipeline`
  - PipelineRun: `upload-directory-to-oci-pipeline-run`

## Quick Start

### 1. Create Credentials Secret

Create a secret with your OCI credentials using this template:

```yaml
# Oracle Cloud Infrastructure (OCI) Credentials Secret Template
# IMPORTANT: Do not commit actual credentials to version control!
# NOTE: If namespace is not provided (in secret or task parameters), it will be auto-detected

apiVersion: v1
kind: Secret
metadata:
  name: oci-credentials
type: Opaque
stringData:
  # REQUIRED: OCI API Private Key (PEM format)
  oci_api_key.pem: |
    -----BEGIN RSA PRIVATE KEY-----
    YOUR_ACTUAL_PRIVATE_KEY_CONTENT_HERE
    -----END RSA PRIVATE KEY-----

  # REQUIRED: API Key Fingerprint
  fingerprint: "YOUR_API_KEY_FINGERPRINT_HERE"

  # OPTIONAL: These can be provided as task parameters instead
  tenancy_ocid: "ocid1.tenancy.oc1..example_tenancy_id"
  user_ocid: "ocid1.user.oc1..example_user_id"
  region: "us-ashburn-1"
  namespace: "your-namespace-here"  # Will be auto-detected if not provided
```

Apply the secret:
```bash
# IMPORTANT: Edit the secret-template.yaml with your actual OCI credentials first!
kubectl apply -f https://github.com/tektoncd/catalog/raw/main/task/oracle-cloud-storage-upload/0.2/samples/secret-template.yaml
```

Alternatively, create the secret directly from the command line:
```bash
kubectl create secret generic oci-credentials \
  --from-file=oci_api_key.pem=~/.oci/oci_api_key.pem \
  --from-literal=fingerprint="12:34:56:78:90:ab:cd:ef:12:34:56:78:90:ab:cd:ef" \
  --from-literal=tenancy_ocid="ocid1.tenancy.oc1..example_tenancy_id" \
  --from-literal=user_ocid="ocid1.user.oc1..example_user_id" \
  --from-literal=region="us-ashburn-1" \
  --from-literal=namespace="your-namespace"  # Optional - auto-detected if omitted
```
### 2. Run Examples

```bash
# Run individual TaskRuns
kubectl apply -f https://github.com/tektoncd/catalog/raw/main/task/oracle-cloud-storage-upload/0.2/samples/taskrun-example.yaml

# Run pipeline examples
kubectl apply -f https://github.com/tektoncd/catalog/raw/main/task/oracle-cloud-storage-upload/0.2/samples/pipeline-upload-single-file.yaml
kubectl apply -f https://github.com/tektoncd/catalog/raw/main/task/oracle-cloud-storage-upload/0.2/samples/pipeline-upload-directory.yaml
```

## Path Options

- `path: "."` - Upload all files from workspace root
- `path: "sample-data/"` - Upload specific directory
- `path: "file.jar"` - Upload single file (includes automatic MD5 hash verification when available)

## Namespace Handling

The `namespace` parameter is optional:
- **When provided**: Saves an API call by using the specified namespace directly
- **When omitted**: Task automatically runs `oci os ns get` to retrieve the namespace
- Recommended to omit unless you need to optimize for fewer API calls

## Sync Behavior

When `deleteExtraFiles: "true"` is set:
- Uses `oci os object sync --delete` command
- Deletes files in bucket that don't exist in source directory
- Only works with `replaceExistingFiles: "true"` (default)
- **⚠️ DANGER**: Can delete data quickly if misconfigured

## Extra Arguments (`extraArgs`)

The `extraArgs` parameter allows passing additional arguments to OCI CLI commands:

### Common Use Cases

**Setting Object Metadata:**
```yaml
extraArgs:
  - "--metadata"
  - '{"application":"myapp","version":"1.0.0","environment":"prod"}'
```

**Performance Tuning:**
```yaml
extraArgs:
  - "--parallel-operations-count"
  - "15"
  - "--part-size"
  - "128"  # MB for multipart uploads
```

**HTTP Headers:**
```yaml
extraArgs:
  - "--cache-control"
  - "max-age=86400"
  - "--content-type"
  - "application/json"
```

**Combining Multiple Arguments:**
```yaml
extraArgs:
  - "--metadata"
  - '{"app":"myapp","env":"prod"}'
  - "--parallel-operations-count"
  - "10"
  - "--cache-control"
  - "no-cache"
```

## Security

- Store credentials in Kubernetes secrets only
- Never commit real credentials to git
- Use least privilege Oracle Cloud Infrastructure IAM policies
