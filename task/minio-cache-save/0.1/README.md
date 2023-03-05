# minio-cache-save

This Task cache dependencies into minio


## Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/minio-cache/0.1/raw
```

## Parameters

* **mc-images**: The minio client image to use (_default:_ bitnami/minio-client:2023 )
* **path**:  A list of files, directories, and wildcard patterns to cache
* **key**: An explicit key for a cache entry
* **server**: MinIO server address (_default:_ [play.min.io](https://play.min.io/))
* **bucket**: MinIO bucket name (_default:_ tektoncd-catalog-play), will create it if not exists

## Workspaces

* **secret**: An optional workspace containing `accessKey` and
  `secretKey` files.

  It is **strongly** recommended that this workspace be bound to a Kubernetes
  `Secret`.

## Usage

This TaskRun runs the Task to cache dependencies into minio

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: example-run
spec:
  taskRef:
    name: minio-cache-save
  params:
    - name: server
      value: https://play.min.io/
    - name: bucket
      value: test
    - name: key
      value: file-key
    - name: path
      value: ./vendor
  workspaces:
  - name: secret
    secret:
      secretName: minio-secret
```
