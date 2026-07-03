# apko Task

This Task builds minimal or distroless container images using [apko](https://github.com/chainguard-dev/apko) from Chainguard.

## Install the Task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/apko/0.1/raw
# or
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/apko/0.1/apko.yaml
```

## Parameters

| Name | Description | Default |
|------|-------------|---------|
| `REGISTRY` | Container registry to push the image to | - |
| `PASSWORD` | Password for the container registry | - |
| `USERNAME` | Username for the container registry | `AWS` |
| `IMAGE` | Name (reference) of the image to build | - |
| `CONFIGFILE` | YAML file that configures the target image | `config.yaml` |
| `CONTEXT` | The build context where apko will search for config files | `./` |
| `EXTRA_ARGS` | Additional arguments to pass to apko | `[]` |
| `BUILDER_IMAGE` | The image on which builds will run | `cgr.dev/chainguard/apko:latest` |

## Workspaces

- **source**: Contains the apko configuration file(s)
- **dockerconfig**: (Optional) Contains a Docker `config.json` for authentication

## Results

- **IMAGE_DIGEST**: Digest of the built image
- **IMAGE_URL**: Full reference URL of the built image

## Example Usage

### Basic Example

This example builds an image using a config file in the repository root:

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: apko-example
spec:
  taskRef:
    name: apko
  workspaces:
    - name: source
      persistentVolumeClaim:
        claimName: my-source
  params:
    - name: REGISTRY
      value: ghcr.io/my-org
    - name: PASSWORD
      valueFrom:
        secretKeyRef:
          name: registry-credentials
          key: password
    - name: USERNAME
      value: my-username
    - name: IMAGE
      value: ghcr.io/my-org/my-app:latest
    - name: CONFIGFILE
      value: apko.yaml
```

### Example apko Configuration

Here's a simple `apko.yaml` configuration:

```yaml
contents:
  repositories:
    - https://dl-cdn.alpinelinux.org/alpine/edge/main
  packages:
    - alpine-baselayout-data
    - busybox
    - ca-certificates-bundle
    - tzdata

accounts:
  groups:
    - groupname: nonroot
      gid: 65532
  users:
    - username: nonroot
      uid: 65532
  run-as: 65532

entrypoint:
  command: /bin/sh -

archs:
  - x86_64
  - arm64
```

### Using Registry Credentials in Tekton

When working with private registries, you can use Kubernetes secrets to store and manage your credentials securely. Here's how to create a secret for a container registry:

```bash
# Create a registry secret
kubectl create secret docker-registry regcred \
  --docker-server=<your-registry-server> \
  --docker-username=<your-username> \
  --docker-password=<your-password> \
  --docker-email=<your-email>
```

Then reference it in your TaskRun or Pipeline:

```yaml
workspaces:
  - name: dockerconfig
    secret:
      secretName: regcred
      items:
        - key: .dockerconfigjson
          path: config.json
```

### Cloud Provider Authentication

#### AWS ECR Authentication

To authenticate with Amazon ECR and get temporary credentials:

```bash
# Login to ECR (requires AWS CLI v2)
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<region>.amazonaws.com

# Get temporary credentials for Tekton
REGISTRY="<aws_account_id>.dkr.ecr.<region>.amazonaws.com"
TOKEN=$(aws ecr get-authorization-token --output text --query 'authorizationData[].authorizationToken' | base64 -d | cut -d: -f2)

# Use these values in your TaskRun:
# - REGISTRY: $REGISTRY
# - USERNAME: AWS
# - PASSWORD: $TOKEN
```

#### Azure Container Registry (ACR) Authentication

To authenticate with Azure Container Registry:

```bash
# Login to ACR (requires Azure CLI)
az login
az acr login --name <acrName>

# Get credentials
REGISTRY="<acrName>.azurecr.io"
TOKEN=$(az acr login --name <acrName> --expose-token --output tsv --query accessToken)

# Use these values in your TaskRun:
# - REGISTRY: $REGISTRY
# - USERNAME: 00000000-0000-0000-0000-000000000000
# - PASSWORD: $TOKEN
```

#### Google Container Registry (GCR) Authentication

For Google Container Registry:

```bash
# Login to GCR (requires gcloud CLI)
gcloud auth login
gcloud auth configure-docker

# Get access token
REGISTRY="gcr.io"
TOKEN=$(gcloud auth print-access-token)

# Use these values in your TaskRun:
# - REGISTRY: $REGISTRY
# - USERNAME: oauth2accesstoken
# - PASSWORD: $TOKEN
```

> **Note:** For production environments, consider using:
> - AWS: IAM roles for service accounts (IRSA)
> - Azure: Managed identities
> - GCP: Workload Identity

### Using with Tekton Pipelines

Here's how you can use the task in a Pipeline:

```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: build-and-deploy
spec:
  workspaces:
    - name: source
    - name: dockerconfig
  tasks:
    - name: build-image
      taskRef:
        name: apko
      workspaces:
        - name: source
          workspace: source
        - name: dockerconfig
          workspace: dockerconfig
      params:
        - name: REGISTRY
          value: ghcr.io/my-org
        - name: PASSWORD
          valueFrom:
            secretKeyRef:
              name: registry-credentials
              key: password
        - name: USERNAME
          value: my-username
        - name: IMAGE
          value: ghcr.io/my-org/my-app:latest
```

## Security

This task runs with minimal privileges by default, dropping all Linux capabilities and running with a non-root user where possible. The build steps require root access for apko to function correctly.

## Changelog

### 0.1

- Initial release of the apko task
