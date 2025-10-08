# OCI Object Storage Upload

This Tekton task uploads files or directories to Oracle Cloud Infrastructure (OCI) Object Storage buckets using the OCI CLI.

## Description

The `oci-upload` task allows to upload files or directories from a workspace to an OCI Object Storage bucket. It supports both single file uploads and bulk directory uploads with optional recursive directory traversal.

## Prerequisites

Before using this task, ensure to have:

1. **Kubernetes cluster with Tekton Pipelines installed**
2. **OCI Account with:**
   - Tenancy OCID and User OCID
   - API Key and Fingerprint
   - Region identifier (e.g., `us-ashburn-1`)
   - Object Storage namespace
3. **Existing OCI Object Storage bucket**

## Parameters

| Parameter | Description | Type | Default |
|-----------|-------------|------|---------|
| `path` | The path to files or directories relative to the source workspace | string | **required** |
| `bucketName` | The name of the OCI Object Storage bucket (without oci:// prefix) | string | **required** |
| `objectPrefix` | The object prefix/path within the bucket where files should be uploaded | string | `""` |
| `tenancyOcid` | The OCID of the OCI tenancy | string | **required** |
| `userOcid` | The OCID of the OCI user | string | **required** |
| `region` | The OCI region identifier | string | **required** |
| `namespace` | The OCI Object Storage namespace (typically your tenancy name) | string | **required** |
| `replaceExistingFiles` | When "false", files that already exist are skipped | string | `"true"` |
| `recursive` | When "true", upload directories recursively | string | `"true"` |
| `privateKeyPath` | The path inside the credentials workspace to the OCI API private key file | string | `oci_api_key.pem` |
| `fingerprintPath` | The path inside the credentials workspace to the file containing the fingerprint | string | `fingerprint` |

## Workspaces

| Workspace | Description |
|-----------|-------------|
| `credentials` | A secret with OCI credentials including API key, fingerprint, and config |
| `source` | A workspace where files will be uploaded from |

## Usage

### 1. Create OCI Credentials Secret

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

### 2. Install the Task

```bash
kubectl apply -f oci-upload.yaml
```

### 3. Create and Run a TaskRun

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: oci-upload-example
spec:
  taskRef:
    name: oci-upload
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
  - name: namespace
    value: "your-oci-namespace"
  workspaces:
  - name: credentials
    secret:
      secretName: oci-credentials
  - name: source
    persistentVolumeClaim:
      claimName: my-source-pvc
```

## Examples

For complete working examples, see the `samples/` directory.
```

## Examples

### Upload a Single File

```yaml
params:
- name: path
  value: "report.pdf"
- name: bucketName
  value: "documents-bucket"
- name: objectPrefix
  value: "reports/2025"
```

This uploads `report.pdf` to `oci://documents-bucket/reports/2025/report.pdf`

### Upload an Entire Directory

```yaml
params:
- name: path
  value: "build-artifacts/"
- name: bucketName
  value: "ci-artifacts"
- name: objectPrefix
  value: "project-x/v1.2.3"
- name: recursive
  value: "true"
```

This uploads all files in `build-artifacts/` to `oci://ci-artifacts/project-x/v1.2.3/`

### Skip Existing Files

```yaml
params:
- name: replaceExistingFiles
  value: "false"
```

Files that already exist in the bucket will be skipped.