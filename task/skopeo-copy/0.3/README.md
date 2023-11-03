# Skopeo


[Skopeo](https://github.com/containers/skopeo) is a command line tool for working with remote image registries. Skopeo doesn’t require a daemon to be running while performing its operations. In particular, the handy skopeo command called `copy` will ease the whole image copy operation. Without further ado, you can copy an image from a registry to another simply by running:
```
skopeo copy docker://internal.registry/myimage:latest /
docker://production.registry/myimage:v1.0
```
The copy command will take care of copying the image from `internal.registry` to `production.registry`

If your production registry requires credentials to login in order to push the image, skopeo can handle that as well.

```
skopeo copy --dest-creds prod_user:prod_pass docker://internal.registry/myimage:latest /
docker://production.registry/myimage:v1.0
```

The same goes for credentials for the source registry (internal.registry) by using the `--src-creds` flag.

It is also useful for copying images between two remote docker registries, such as the registries of two different OpenShift clusters, as shown
```
skopeo copy docker://busybox:latest oci:busybox_ocilayout:latest
```
Skopeo copy isn’t limited to remote containers registries. The image prefix `docker://` from the above command define the transport to be used when handling the image.

There are others also similar to that:

- atomic
- containers-storage
- dir
- docker
- docker-daemon
- docker-tar
- oci
- ostree

This `task` can be used to copy one or more than one images to-and fro various storage mechanisms.

## Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/skopeo-copy/0.3/raw
```

## Parameters

- **srcImageURL**: The URL of the image to be copied to the `destination` registry.
- **destImageURL**: The URL of the image where the image from `source` should be copied to.
- **srcTLSverify**: Verify the TLS on the src registry endpoint
- **destTLSverify**: Verify the TLS on the dest registry endpoint

## Workspace

- **images-url**: To mount file containing multiple source and destination images registries URL, which is mounted as configMap.


## Secrets and ConfigMap
* `Secret` to provide the credentials of the source and destination registry where the image needs to be copied from and to.
* `ConfigMap` to provide support for copying multiple images, this contains file `url.txt` which stores images registry URL's.

  [This](../0.3/samples/quay-secret.yaml) example can help to use secrets for providing credentials of image registries.

## Platforms

The Task can be run on `linux/amd64`, `linux/s390x`, `linux/arm64` and `linux/ppc64le` platforms.

## Usage

This task will use the `Service Account` with access to the secrets containing source and destination image registry credentials, this will authorize it to the respective image registries.

In case of multiple source and destination image registries that needs to be copied to and from a file named `url.txt` should be created containing all the source and destination image registries `URL` seperated by a space and each set of images should be written in the new line, as shown below.

```
docker://quay.io/temp/kubeconfigwriter:v1 docker://quay.io/skopeotest/kube:v1
docker://quay.io/temp/kubeconfigwriter:v2 docker://quay.io/skopeotest/kube:v2
```

`ConfigMap` should be created using this file. Following `command` can be used to create configMap from the `file`.
```
kubectl create configmap image-configmap --from-file=url.txt
```
In case there is only one source and destination image that needs to be copied then, Source and destination image URL needs to be provided in the input params of the task.

This will result in the image getting copied from the source registry to the destination registry.


[This](../0.3/samples/serviceaccount.yaml) will guide the user to use service account for authorization to image registries.

See [here](../0.3/samples/run.yaml) for example of `TaskRun`.
### Note

- `Source credentials` are only required, if the source image registry needs authentication to pull the image, whereas `Destination credentials` are always required.

- In case of multiple source and destination images, `secret` containing `credentials` of all the image registries must be added to the `service account` and configMap containing `url.txt` should be mounted into the workspace, as shown
    ```
    workspaces:
      - name: images-url
        configmap:
          name: image-configmap
    ```


- If there is only one source and destination image registry URL, then `emptyDir` needs to be mounted in the `workspace` as shown below:

    ```
    workspaces:
      - name: images-url
        emptyDir: {}
    ```
