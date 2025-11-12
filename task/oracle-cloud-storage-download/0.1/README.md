# Oracle Cloud Storage Download

This Task downloads files or directories from an Oracle Cloud Infrastructure (OCI) Object Storage bucket to a Tekton workspace using the OCI CLI. It leverages the [`oci os object get`](https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/cmdref/os/object.html) and [`oci os object bulk-download`](https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/cmdref/os/object.html) commands.

## Install the Task

```bash
kubectl apply -f oracle-cloud-storage-download.yaml
```

## Parameters

* **path**: Path relative to output workspace where files will be downloaded. (_required_)
* **bucketName**: Source OCI Object Storage bucket name. (_required_)
* **objectPrefix**: Object prefix/path within the bucket to download from. (_default_: `""`)
* **tenancyOcid**: OCI tenancy OCID (optional if provided via credentials secret). (_default_: `""`)
* **userOcid**: OCI user OCID (optional if provided via credentials secret). (_default_: `""`)
* **region**: OCI region identifier (e.g., us-ashburn-1). (_default_: `""`)
* **namespace**: OCI Object Storage namespace (optional, auto-detectable). (_default_: `""`)
* **typeDir**: Set to "true" if downloading a directory. (_default_: `"false"`)
* **recursive**: Download directories recursively (only applies when typeDir is true). (_default_: `"true"`)
* **overwrite**: Overwrite existing files in the output workspace. (_default_: `"true"`)
* **privateKeyPath**: Path inside credentials workspace to API private key file. (_default_: `"oci_api_key.pem"`)
* **fingerprintPath**: Path inside credentials workspace to fingerprint file. (_default_: `"fingerprint"`)
* **extraArgs**: Additional arguments to pass to OCI CLI. (_default_: `[]`)

## Workspaces

* **credentials**: A workspace containing OCI credentials (API key, fingerprint, etc.). This workspace should be populated from a Secret.
* **output**: A workspace where downloaded files or directories will be placed.

## Platforms

The Task can be run on `linux/amd64` and `linux/arm64` platforms.

## Usage

### Basic File Download

Download a single file from OCI Object Storage:

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: download-file
spec:
  taskRef:
    name: oracle-cloud-storage-download
  params:
  - name: path
    value: "."
  - name: bucketName
    value: "my-bucket"
  - name: objectPrefix
    value: "uploads/hello.txt"
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
  - name: output
    emptyDir: {}
```

### Directory Download

Download a directory (with all files under a prefix):

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: download-directory
spec:
  taskRef:
    name: oracle-cloud-storage-download
  params:
  - name: path
    value: "."
  - name: bucketName
    value: "my-bucket"
  - name: objectPrefix
    value: "previous/v1.0.0"
  - name: typeDir
    value: "true"
  workspaces:
  - name: credentials
    secret:
      secretName: oci-credentials
  - name: output
    persistentVolumeClaim:
      claimName: workspace-pvc
```

### Download with Secret Configuration

Use a secret that contains all OCI configuration:

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: download-with-secret
spec:
  taskRef:
    name: oracle-cloud-storage-download
  params:
  - name: path
    value: "downloaded-artifacts"
  - name: bucketName
    value: "my-bucket"
  - name: objectPrefix
    value: "artifacts"
  - name: typeDir
    value: "true"
  workspaces:
  - name: credentials
    secret:
      secretName: oci-credentials-complete  # Contains all config in secret
  - name: output
    emptyDir: {}
```

### Using in a Pipeline

```yaml
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: clone-from-oci
spec:
  params:
  - name: bucket
    description: OCI bucket name
  - name: release-tag
    description: Release tag to download
  workspaces:
  - name: shared
  - name: credentials
  tasks:
  - name: clone-bucket
    taskRef:
      resolver: bundles
      params:
        - name: bundle
          value: ghcr.io/your-org/catalog/tasks/oracle-cloud-storage-download:0.1
        - name: name
          value: oracle-cloud-storage-download
        - name: kind
          value: task
    params:
      - name: path
        value: .
      - name: bucketName
        value: $(params.bucket)
      - name: objectPrefix
        value: previous/$(params.release-tag)
      - name: typeDir
        value: "true"
    workspaces:
      - name: output
        workspace: shared
        subPath: release
      - name: credentials
        workspace: credentials
```

### Advanced Download with Extra Arguments

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: download-with-extra-args
spec:
  taskRef:
    name: oracle-cloud-storage-download
  params:
  - name: path
    value: "."
  - name: bucketName
    value: "my-bucket"
  - name: objectPrefix
    value: "large-dataset"
  - name: typeDir
    value: "true"
  - name: extraArgs
    value:
    - "--parallel-operations-count"
    - "10"
  workspaces:
  - name: credentials
    secret:
      secretName: oci-credentials
  - name: output
    persistentVolumeClaim:
      claimName: workspace-pvc
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
  namespace: "your-namespace-here"  # Optional - will be auto-detected if not provided
```

**Important**: Never commit actual credentials to version control!

## How It Works

1. **Configuration**: The task reads OCI credentials from the credentials workspace and parameters
2. **Validation**: Validates the OCI configuration by testing API access
3. **Namespace Detection**: Auto-detects the Object Storage namespace if not provided
4. **Download**: 
   - For single files (`typeDir=false`): Uses `oci os object get`
   - For directories (`typeDir=true`): Uses `oci os object bulk-download`
5. **Output**: Places downloaded files in the output workspace at the specified path

## Troubleshooting

### Authentication Errors

If you see authentication errors:
1. Verify your API key fingerprint matches the one in OCI Console
2. Ensure the private key file is in PEM format
3. Check that user OCID has proper permissions on the bucket
4. Verify the region is correct

### Namespace Detection Fails

If auto-detection fails:
- Provide the namespace explicitly via the `namespace` parameter or credentials secret
- Find your namespace in OCI Console under Object Storage

### Permission Errors

Ensure your OCI user has the following policies:
```
Allow user <user-name> to read objects in compartment <compartment-name>
Allow user <user-name> to read buckets in compartment <compartment-name>
```

## See Also

- [OCI CLI Documentation](https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/)
- [OCI Object Storage Documentation](https://docs.oracle.com/en-us/iaas/Content/Object/home.htm)
- [Oracle Cloud Storage Upload Task](../oracle-cloud-storage-upload) - Companion task for uploading
