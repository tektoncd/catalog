# Buildah Manifest Create

This Task creates a manifest list (also known as an image index) from pre-built architecture-specific images using [Buildah](https://github.com/containers/buildah). It uses Buildah's `manifest create` and `manifest add` commands to create multi-architecture container images locally.

## Install the Task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/buildah-manifest-create/0.1/raw
```

## Parameters

* **MANIFEST_IMAGE**: Reference of the manifest list image to create (e.g., `registry.io/myimage:latest`)
* **IMAGE_REFS**: Array of image references to include in the manifest list. Can be full registry references (e.g., `registry.io/myimage:latest-amd64`) or bare digests for local storage (e.g., `sha256:abc123`)
* **BUILDER_IMAGE**: The location of the buildah builder image (_default:_ `quay.io/buildah/stable:v1`)
* **STORAGE_DRIVER**: Set buildah storage driver (_default:_ `overlay`)

## Results

* **MANIFEST_IMAGE**: Local manifest list reference that was created

## Workspaces

* **buildah-storage**: A [Workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md) for buildah storage. This workspace should be shared between buildah-manifest-create and buildah-manifest-push tasks to persist the created manifest list.
* **dockerconfig**: An [*optional* Workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md#optional-workspaces) that allows providing a `.docker/config.json` file for Buildah to access the container registry. The file should be placed at the root of the Workspace with name `config.json`.

## Platforms

The Task can be run on `linux/amd64`, `linux/s390x`, `linux/arm64` and `linux/ppc64le` platforms.

## Usage

This TaskRun creates a manifest list from pre-built architecture-specific images.

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: buildah-manifest-create-example
spec:
  taskRef:
    name: buildah-manifest-create
  params:
  - name: MANIFEST_IMAGE
    value: registry.example.com/my-repo/my-image:latest
  - name: IMAGE_REFS
    value:
    - registry.example.com/my-repo/my-image:latest-amd64
    - registry.example.com/my-repo/my-image:latest-arm64
  workspaces:
  - name: buildah-storage
    persistentVolumeClaim:
      claimName: buildah-storage-pvc
```

This task is typically used as part of a multi-architecture build pipeline after building individual architecture images with the `buildah` task.