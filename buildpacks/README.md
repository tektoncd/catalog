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

## Inputs

### Parameters

* **IMAGE:** The image you wish to create. For example, "repo/example", or
  "example.com/repo/image". (_required_)
* **RUN_IMAGE:** The run image buildpacks will use as the base for IMAGE.
  (_default:_ `packs/run:v3alpha2`)
* **BUILDER_IMAGE** The image on which builds will run. ( default:
  `packs/samples:v3alpha2`)
* **USE_CRED_HELPERS:** Use Docker credential helpers. Set to `"true"` or
  `"false"` as string values. (_default:_ `"true"`)
* **CACHE** The name of the persistent app cache volume (_default:_ an empty
  directory -- effectively no cache)
* **USER_ID** The user ID of the builder image user (_default:_ 1000)
* **GROUP_ID** The group ID of the builder image user (_default:_ 1000)

### Resources

* **source**: A `git`-type `PipelineResource` specifying the location of the
  source to build.

## Usage

This TaskRun runs the Task to fetch a Git repo, and build and push a container
image using buildpacks.

```
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  name: example-run
spec:
  taskRef:
    name: buildpacks-v3
  inputs:
    params:
    - name: IMAGE
      value: gcr.io/my-repo/my-image:tag
    resources:
    - name: source
      resourceSpec:
        type: git
        params:
        - name: url
          value: https://github.com/my-user/my-repo
```
