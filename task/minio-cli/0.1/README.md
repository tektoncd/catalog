## MinIO CLI Task

[MinIO](http://minio.io/) is a High Performance Object Storage released under Apache License v2.0.
Its API is compatible with Amazon S3 cloud storage service.

Please, check the MinIO Client (mc) documentation for more information: https://docs.min.io/docs/minio-client-complete-guide

## Purpose of this Task

This task use the MinIO server [play.min.io](https://play.min.io) which is basically a playground for testing.

This task can be used to interact with the MinIO server through a MinIO client.

## Install the Task and create a secret

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/minio-cli/0.1/minio-cli.yaml
```

Create the secrets that has the access-key and secret-key token.

Example minio-key-tokens.yaml
```
kind: Secret
apiVersion: v1
metadata:
  name: key-tokens
stringData:
  access-token: {token over here}
  secret-token: {token over here}
```

Example kubectl command
```
kubectl apply -f minio-key-tokens.yaml
```

## Parameters

* **server-url**: The URL of the MinIO server.

* **server-alias**: Alias for the MinIO server.

* **key-tokens**: The name of the secret that has the access-key and secret-key tokens to authenticate to the MinIO server.

* **cli-command**: The command that will be executed by the MinIO client.

## Usage

This task will execute a basic command that will list buckets and objects on the server.

```
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: run-minio-cli
spec:
  params:
  - name: server-url
    value: "https://play.min.io"
  - name: server-alias
    value: "mco"
  - name: key-tokens
    value: "key-tokens"
  - name: cli-command
    value: "ls"
  taskRef:
    name: minio-cli
```