# Cloud Native Buildpacks

This build template builds source into a container image using [Cloud Native
Buildpacks](https://buildpacks.io).

The Cloud Native Buildpacks website describes v3 buildpacks as:

> ... pluggable, modular tools that translate source code into container-ready
> artifacts such as OCI images. They replace Dockerfiles in the app development
> lifecycle with a higher level of abstraction. ...  Cloud Native Buildpacks
> embrace modern container standards, such as the OCI image format. They take
> advantage of the latest capabilities of these standards, such as remote image
> layer rebasing on Docker API v2 registries.

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/buildpacks/buildpacks-v3.yaml
```

> **NOTE:** This task is currently only compatible with Tekton **v0.6.0** and above.

## Inputs

### Parameters

* **BUILDER_IMAGE** The image on which builds will run (must include v3 lifecycle and compatible buildpacks; _required_)
* **USE_CRED_HELPERS:** Use Docker credential helpers. Set to `"true"` or
  `"false"` as string a value. (_default:_ `"false"`)
* **CACHE** The name of the persistent app cache volume (_default:_ an empty
  directory -- effectively no cache)
* **USER_ID** The user ID of the builder image user, as a string value (_default:_ `"1000"`)
* **GROUP_ID** The group ID of the builder image user, as a string value (_default:_ `"1000"`)

### Resources

* **source**: A `git`-type `PipelineResource` specifying the location of the
  source to build.

## Outputs

### Resources

* **image**: An `image`-type `PipelineResource` specifying the image that should
  be built.

## Usage

This `TaskRun` will use the `buildpacks-v3` task to fetch source code from a Git repo, build the source code, then publish a container image.

```
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  name: example-run
spec:
  taskRef:
    name: buildpacks-v3
  podTemplate:
    volumes:
    - name: my-cache
      persistentVolumeClaim:
        claimName: my-volume-claim
  inputs:
    resources:
    - name: source
      resourceSpec:
        type: git
        params:
        - name: url
          value: https://github.com/my-user/my-repo
    params:
    - name: BUILDER_IMAGE
      value: gcr.io/cncf-buildpacks-ci/tekton-cnb-test:bionic
    - name: CACHE
      value: my-cache
  outputs:
    resources:
    - name: image
      resourceSpec:
        type: image
        params:
        - name: url
          value: gcr.io/my-repo/my-image
```
