# Oracle Cloud Storage Upload

This Task uploads files or directories from a Tekton workspace to an Oracle Cloud Infrastructure (OCI) Object Storage bucket using the OCI CLI. It leverages the [`oci os object put`](https://docs.oracle.com/en-us/iaas/tools/oci-cli/3.68.0/oci_cli_docs/cmdref/os/object.html) and [`oci os object bulk-upload`](https://docs.oracle.com/en-us/iaas/tools/oci-cli/3.68.0/oci_cli_docs/cmdref/os/object.html) commands.

## Install the Task

```bash
kubectl apply -f oracle-cloud-storage-upload.yaml
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

The Task can be run on `linux/amd64` platform.

## Usage

### Basic File Upload

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: upload-file
spec:
  taskRef:
    name: oracle-cloud-storage-upload
  params:
  - name: path
    value: "hello.txt"
  - name: bucketName
    value: "my-bucket"
  - name: objectPrefix
    value: "uploads"
  - name: tenancyOcid
    value: "ocid1.tenancy.oc1..example_tenancy_id"
  - name: userOcid
    value: "ocid1.user.oc1..example_user_id"
  - name: region
    value: "us-phoenix-1"
  workspaces:
  - name: credentials
    secret:
      secretName: oci-credentials
  - name: source
    emptyDir: {}
```

### Directory Upload with Secret Configuration

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
    value: "build-artifacts"
  - name: bucketName
    value: "my-bucket"
  - name: recursive
    value: "true"
  workspaces:
  - name: credentials
    secret:
      secretName: oci-credentials-complete
  - name: source
    emptyDir: {}
```

### Advanced Upload with Extra Arguments

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: upload-with-metadata
spec:
  taskRef:
    name: oracle-cloud-storage-upload
  params:
  - name: path
    value: "releases"
  - name: bucketName
    value: "my-bucket"
  - name: extraArgs
    value:
    - "--metadata"
    - '{"application":"myapp","version":"2.0.0"}'
    - "--parallel-operations-count"
    - "10"
  workspaces:
  - name: credentials
    secret:
      secretName: oci-credentials
  - name: source
    emptyDir: {}
```

## Credentials Setup

Create a secret with your OCI credentials:

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
- Sync capabilities with `deleteExtraFiles` option
- Configurable timeouts and parallel operations
- Security-focused: runs as non-root user

The `extraArgs` parameter allows you to pass additional command-line arguments to the OCI CLI commands. This is useful for:

- Setting object metadata: `["--metadata", '{"key":"value"}']`
- Controlling parallel uploads: `["--parallel-operations-count", "10"]`
- Setting part size for multipart uploads: `["--part-size", "100"]`
- Adding cache control headers: `["--cache-control", "max-age=3600"]`
- Setting content type: `["--content-type", "application/json"]`

## Workspaces

| Workspace | Description |
|-----------|-------------|
| `credentials` | A secret with Oracle Cloud Infrastructure credentials including API key, fingerprint, and optionally tenancy_ocid, user_ocid, region, and namespace files |
| `source` | A workspace where files will be uploaded from |

## Usage

### 1. Create Oracle Cloud Infrastructure Credentials Secret

#### Option A: Minimal Secret (use parameters for configuration)

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: oci-credentials
type: Opaque
stringData:
  oci_api_key.pem: |
    -----BEGIN RSA PRIVATE KEY-----
    YOUR_PRIVATE_KEY_CONTENT_HERE
    -----END RSA PRIVATE KEY-----
  fingerprint: "your:api:key:fingerprint:here"
```

#### Option B: Complete Secret (fewer parameters needed)

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: oci-credentials-complete
type: Opaque
stringData:
  oci_api_key.pem: |
    -----BEGIN RSA PRIVATE KEY-----
    YOUR_PRIVATE_KEY_CONTENT_HERE
    -----END RSA PRIVATE KEY-----
  fingerprint: "your:api:key:fingerprint:here"
  tenancy_ocid: "ocid1.tenancy.oc1..your-tenancy-ocid"
  user_ocid: "ocid1.user.oc1..your-user-ocid"
  region: "us-ashburn-1"
  namespace: "your-ocs-namespace"  # Optional - can be omitted for auto-detection
```

### 2. Install the Task

```bash
kubectl apply -f oracle-cloud-storage-upload.yaml
```

### 3. Create and Run a TaskRun

#### Using Minimal Secret (Option A)

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: oracle-cloud-storage-upload-example
spec:
  taskRef:
    name: oracle-cloud-storage-upload
  params:
  - name: path
    value: "my-files/"
  - name: bucketName
    value: "my-storage-bucket"
  - name: tenancyOcid
    value: "ocid1.tenancy.oc1..your-tenancy-ocid"
  - name: userOcid
    value: "ocid1.user.oc1..your-user-ocid"
  - name: region
    value: "us-ashburn-1"
  # namespace parameter omitted - will be obtained automatically
  workspaces:
  - name: credentials
    secret:
      secretName: oci-credentials
  - name: source
    persistentVolumeClaim:
      claimName: my-source-pvc
```

#### Using Complete Secret (Option B - Simplified)

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: oracle-cloud-storage-upload-simple
spec:
  taskRef:
    name: oracle-cloud-storage-upload
  params:
  - name: path
    value: "my-files/"
  - name: bucketName
    value: "my-storage-bucket"
  # All OCI configuration is in the secret - no parameters needed!
  workspaces:
  - name: credentials
    secret:
      secretName: oci-credentials-complete
  - name: source
    persistentVolumeClaim:
      claimName: my-source-pvc
```

#### TaskRun with Extra Arguments

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: oracle-cloud-storage-upload-advanced
spec:
  taskRef:
    name: oracle-cloud-storage-upload
  params:
  - name: path
    value: "app-build/"
  - name: bucketName
    value: "production-artifacts"
  - name: extraArgs
    value:
      - "--metadata"
      - '{"version":"1.0.3","environment":"production","build-id":"12345"}'
      - "--parallel-operations-count"
      - "10"
      - "--part-size"
      - "100"
  workspaces:
  - name: credentials
    secret:
      secretName: oci-credentials-complete
  - name: source
    persistentVolumeClaim:
      claimName: my-source-pvc
```

### Skip Existing Files

```yaml
params:
- name: replaceExistingFiles
  value: "false"
```

Files that already exist in the bucket will be skipped.

### Synchronize with Delete Extra Files

```yaml
params:
- name: path
  value: "build-artifacts/"
- name: bucketName
  value: "ci-artifacts"
- name: objectPrefix
  value: "project-x/v1.2.3"
- name: deleteExtraFiles
  value: "true"
```

This synchronizes `build-artifacts/` with `ci-artifacts/project-x/v1.2.3/`, deleting any files in the bucket that don't exist in the local directory.

**⚠️ WARNING**: `deleteExtraFiles` can delete data quickly if you specify the wrong source/destination combination. Be cautious while using this option!

**Note**: Setting `deleteExtraFiles: "true"` is not compatible with `replaceExistingFiles: "false"`.

For complete working examples, see the `samples/` directory.