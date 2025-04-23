# Jumpstarter Release Lease Task

This Tekton task releases an existing lease in the [Jumpstarter](https://github.com/jumpstarter-dev/jumpstarter) system using the `jmp` CLI.

## Install the Task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/jumpstarter-release-lease/0.1/raw
```

## Parameters
- **jmp-lease-id**: The ID of the lease to release. (Required)
- **client-name**: The client intending to acquire the lease. (_default:_: default)

## Secrets

Secret containing the `ClientConfig` file used by the task to acquire the lease for the specified client.

```yaml
apiVersion: jumpstarter.dev/v1alpha1
kind: ClientConfig
metadata:
  namespace: jumpstarter
  name: default
endpoint: grpc.jumpstarter.apps.cluster.com:443
tls:
  ca: ''
  insecure: true
token: token
grpcOptions: {}
drivers:
  allow: []
  unsafe: true
```
The ClientConfig can be created using the jmp CLI. For additional information, please see [Create a Client](https://docs.jumpstarter.dev/getting-started/setup-exporter-client.html#create-a-client).

```yaml
kind: Secret
apiVersion: v1
metadata:
  name: jumpstarter-client
data:
  default.yaml: ClientConfig-file-content
type: Opaque
```

## Workspaces
- **jumpstarter-client-secret**: Mounts the Jumpstarter opaque secret containing the client config data. The secret should include a key named default.yaml with the client config content as its value.

## Platforms
The Task can be run on `linux/amd64` and `linux/arm64` platforms.

## Usage
```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: jumpstarter-release-lease-run
spec:
  taskRef:
    name: jumpstarter-release-lease
  params:
    - name: client-name
      value: "my-client"
    - name: jmp-lease-id
      value: "lease-abc123"
  workspaces:
    - name: jumpstarter-client-secret
      secret:
        secretName: jumpstarter-client
```