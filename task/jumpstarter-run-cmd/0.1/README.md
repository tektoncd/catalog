# Jumpstarter Run Command Task

This Tekton task runs one or more commands on a remote device using the [Jumpstarter](https://github.com/jumpstarter-dev/jumpstarter) system and a valid lease.

## Install the Task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/jumpstarter-run-command/0.1/raw
```

## Parameters
- **jmp-lease-id**: The lease ID used to execute the command. (Required)
- **client-name**: The client configuration to use. (_default_: default)
- **jmp-jScript**: The command(s) to execute inside the remote environment. (Required)
- **image**: The container image containing the jmp CLI. (_default_: quay.io/jumpstarter-dev/jumpstarter:0.6.0)
- **home**: Home directory for the container image user. (_default_: /root)

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
- **source**: Contains source code, input files, or image content required for command execution. The task executes commands from this workspace.

## Platforms
The Task can be run on `linux/amd64` and `linux/arm64` platforms.

## Usage
```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: jumpstarter-run-command-run
spec:
  taskRef:
    name: jumpstarter-run-command
  params:
    - name: client-name
      value: "my-client"
    - name: jmp-lease-id
      value: "lease-abc123"
    - name: jmp-jScript
      value: |
        echo Hello from Jumpstarter
        j power on 
  workspaces:
    - name: jumpstarter-client-secret
      secret:
        secretName: jumpstarter-client
    - name: source
      emptyDir: {}
```