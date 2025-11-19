# Oracle Cloud Storage Upload

This Task uploads files or directories from a Tekton workspace to an Oracle Cloud Infrastructure (OCI) Object Storage bucket using the OCI CLI. It leverages the [`oci os object put`](https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/cmdref/os/object.html) and [`oci os object bulk-upload`](https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/cmdref/os/object.html) commands.

## Install the Task

```bash
kubectl apply -f https://github.com/tektoncd/catalog/raw/main/task/oracle-cloud-storage-upload/0.2/oracle-cloud-storage-upload.yaml
```

## Parameters

* **path**: Path relative to source workspace to upload. (_required_)
* **bucketName**: Target OCI Object Storage bucket name. (_required_)
* **objectPrefix**: Object prefix/path within the bucket. (_default_: `""`)
* **tenancyOcid**: OCI tenancy OCID (optional if provided via credentials secret). (_default_: `""`)
* **userOcid**: OCI user OCID (optional if provided via credentials secret). (_default_: `""`)
* **region**: OCI region identifier (e.g., us-ashburn-1). (_default_: `""`)
* **namespace**: OCI Object Storage namespace (optional, auto-detectable). (_default_: `""`)
* **replaceExistingFiles**: Skip files if they already exist when false. (_default_: `"true"`)
* **recursive**: Upload directories recursively. (_default_: `"true"`)
* **deleteExtraFiles**: Delete extra remote files not found locally. **WARNING: Use carefully.** (_default_: `"false"`)
* **privateKeyPath**: Path inside credentials workspace to API private key file. (_default_: `"oci_api_key.pem"`)
* **fingerprintPath**: Path inside credentials workspace to fingerprint file. (_default_: `"fingerprint"`)
* **enableMd5Validation**: Enable MD5 checksum validation for file uploads. (_default_: `"true"`)
* **extraArgs**: Additional arguments to pass to OCI CLI. (_default_: `[]`)

## Workspaces

* **credentials**: A workspace containing OCI credentials (API key, fingerprint, etc.). This workspace should be populated from a Secret.
* **source**: A workspace containing files or directories to upload.

## Platforms

The Task can be run on `linux/amd64` and `linux/arm64` platforms.

## Usage

See the [samples](samples/) directory for complete, runnable examples including:
- **taskrun-example.yaml**: Multiple upload scenarios (simple, with secret, sync, with metadata)
- **pipeline-upload-single-file.yaml**: Pipeline example for single file upload
- **pipeline-upload-directory.yaml**: Pipeline example for directory upload with bundle resolver

For detailed usage instructions, see [samples/README.md](samples/README.md).

### Quick Example

Upload a directory to OCI Object Storage:

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: upload-directory
spec:
  taskRef:
    name: oracle-cloud-storage-upload
  params:
  - name: path
    value: "build-artifacts/"
  - name: bucketName
    value: "my-bucket"
  - name: objectPrefix
    value: "releases/v1.0.0"
  workspaces:
  - name: credentials
    secret:
      secretName: oci-credentials
  - name: source
    persistentVolumeClaim:
      claimName: workspace-pvc
```

### Using with Bundle Resolver

Reference the task directly without installation:

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: upload-with-bundle
spec:
  taskRef:
    resolver: bundles
    params:
      - name: bundle
        value: ghcr.io/tektoncd/catalog/upstream/oracle-cloud-storage-upload:0.2
      - name: name
        value: oracle-cloud-storage-upload
      - name: kind
        value: task
  params:
  - name: path
    value: "app.jar"
  - name: bucketName
    value: "my-bucket"
  - name: objectPrefix
    value: "artifacts"
  - name: enableMd5Validation
    value: "true"
  workspaces:
  - name: credentials
    secret:
      secretName: oci-credentials
  - name: source
    emptyDir: {}
```

## Credentials Setup

### Create OCI Credentials Secret

You can create the credentials secret in two ways:

#### Option 1: Using kubectl with files

```bash
kubectl create secret generic oci-credentials \
  --from-file=oci_api_key.pem=~/.oci/oci_api_key.pem \
  --from-literal=fingerprint="12:34:56:78:90:ab:cd:ef:12:34:56:78:90:ab:cd:ef" \
  --from-literal=tenancy_ocid="ocid1.tenancy.oc1..example_tenancy_id" \
  --from-literal=user_ocid="ocid1.user.oc1..example_user_id" \
  --from-literal=region="us-ashburn-1"
```

#### Option 2: Using YAML

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: oci-credentials
type: Opaque
stringData:
  oci_api_key.pem: |
    -----BEGIN RSA PRIVATE KEY-----
    YOUR_ACTUAL_PRIVATE_KEY_CONTENT_HERE
    -----END RSA PRIVATE KEY-----
  fingerprint: "YOUR_API_KEY_FINGERPRINT_HERE"
  tenancy_ocid: "ocid1.tenancy.oc1..example_tenancy_id"
  user_ocid: "ocid1.user.oc1..example_user_id"
  region: "us-ashburn-1"
  namespace: "your-namespace-here"  # Optional - auto-detected if omitted
```

**Note**: If namespace is not provided (in secret or task parameters), it will be auto-detected.

## Features

- Supports both single file and directory uploads
- Automatic MD5 validation for data integrity (single files)
- Auto-detection of OCI Object Storage namespace
- Flexible authentication (parameters or secrets)
- Sync capabilities with `deleteExtraFiles` option (**use with caution!**)
- Configurable parallel operations via `extraArgs`
- Security-focused: runs as non-root user (UID 65532)

### Extra Arguments

The `extraArgs` parameter allows additional OCI CLI arguments:

- Setting object metadata: `["--metadata", '{"key":"value"}']`
- Controlling parallel uploads: `["--parallel-operations-count", "10"]`
- Setting part size for multipart uploads: `["--part-size", "100"]`
- Adding cache control headers: `["--cache-control", "max-age=3600"]`
- Setting content type: `["--content-type", "application/json"]`

## How It Works

1. **Configuration**: Reads OCI credentials from credentials workspace and parameters
2. **Validation**: Validates OCI configuration by testing API access  
3. **Namespace Detection**: Auto-detects Object Storage namespace if not provided
4. **MD5 Calculation**: For single files, calculates MD5 hash for data integrity (if enabled)
5. **Upload**:
   - For single files: Uses `oci os object put` with optional MD5 validation
   - For directories: Uses `oci os object bulk-upload` or `oci os object sync` (if deleteExtraFiles is true)
6. **Verification**: OCI validates the upload and returns success/failure

## Namespace Handling

The `namespace` parameter is optional:
- **When provided**: Saves an API call by using the specified namespace directly
- **When omitted**: Task automatically runs `oci os ns get` to retrieve the namespace
- Recommended to omit unless you need to optimize for fewer API calls

## Troubleshooting

If you encounter issues:

1. **Authentication Errors**: Verify your API key, fingerprint, tenancy OCID, user OCID, and region are correct
2. **Namespace Detection Fails**: Provide the namespace explicitly in the secret or as a parameter
3. **Upload Failures**: Check bucket existence, permissions, and network connectivity
4. **MD5 Validation Errors**: Ensure files aren't being modified during upload, or disable validation with `enableMd5Validation: "false"`

For complete working examples, see the `samples/` directory.
