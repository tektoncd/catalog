# Jumpstarter Get Lease Task

This Tekton task acquires a lease from the [Jumpstarter](https://github.com/jumpstarter-dev/jumpstarter) system using label-based selection and returns the lease ID.

## Install the Task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/jumpstarter-get-lease/0.1/raw
```

## Parameters
- **client-name**: The client intending to acquire the lease. (_default:_: default)
- **exporter-labels**: A list of label selectors in the format key=value used to identify exporters. (Required)
- **timeout**: Max wait time (in seconds) before lease request times out. (_default:_: 3600)
- **lease-duration**: Maximum time to hold the lease in HH:MM:SS format. (_default:_: 02:00:00)

## Results
- **jmp-lease-id**: The acquired Jumpstarter lease ID.

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
  name: jumpstarter-get-lease-run
spec:
  taskRef:
    name: jumpstarter-get-lease
  params:
    - name: client-name
      value: "my-client"
    - name: exporter-labels
      value:
        - "board=my-board"
        - "type=board-type"
    - name: timeout
      value: "120"
    - name: lease-duration
      value: "01:00:00"
  workspaces:
    - name: jumpstarter-client-secret
      secret:
        secretName: jumpstarter-client
```