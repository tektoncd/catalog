# Buildah Manifest Push

This Task pushes a locally created manifest list to a container registry using [Buildah](https://github.com/containers/buildah). It uses Buildah's `manifest push` command to publish multi-architecture container images.

## Install the Task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/buildah-manifest-push/0.1/raw
```

## Parameters

* **MANIFEST_IMAGE**: Reference of the manifest list image to push (e.g., `registry.io/myimage:latest`)
* **BUILDER_IMAGE**: The location of the buildah builder image (_default:_ `quay.io/buildah/stable:v1`)
* **STORAGE_DRIVER**: Set buildah storage driver (_default:_ `overlay`)
* **TLSVERIFY**: Verify the TLS on the registry endpoint (_default:_ `true`)
* **FORMAT**: Manifest list type (oci or v2s2) to use when pushing (_default:_ `oci`)
* **PUSH_EXTRA_ARGS**: Extra parameters passed for the push command (_default:_ `""`)

## Results

* **MANIFEST_DIGEST**: Digest of the manifest list that was pushed
* **MANIFEST_URL**: Image repository where the manifest list was pushed

## Workspaces

* **buildah-storage**: A [Workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md) for buildah storage. This workspace should be shared between buildah-manifest-create and buildah-manifest-push tasks to access the created manifest list.
* **sslcertdir**: An [*optional* Workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md#optional-workspaces) containing your custom SSL certificates to connect to the registry.
* **dockerconfig**: An [*optional* Workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md#optional-workspaces) that allows providing a `.docker/config.json` file for Buildah to access the container registry. The file should be placed at the root of the Workspace with name `config.json`.

## Platforms

The Task can be run on `linux/amd64`, `linux/s390x`, `linux/arm64` and `linux/ppc64le` platforms.

## Usage

This TaskRun pushes a locally created manifest list to a container registry.

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: buildah-manifest-push-example
spec:
  taskRef:
    name: buildah-manifest-push
  params:
  - name: MANIFEST_IMAGE
    value: registry.example.com/my-repo/my-image:latest
  workspaces:
  - name: buildah-storage
    persistentVolumeClaim:
      claimName: buildah-storage-pvc
```

This task should be run after creating a manifest list with the `buildah-manifest-create` task.