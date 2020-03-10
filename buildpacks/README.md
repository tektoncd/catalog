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

> **NOTE:** This task is currently only compatible with Tekton **v0.6.0** and above, and CNB Platform API 0.2 (lifecycle v0.6.0 and above). For previous Platform API versions, [see below](#previous-platform-api-versions).

## Parameters

* **`BUILDER_IMAGE`**: The image on which builds will run (must include v3 lifecycle and compatible buildpacks; _required_)

* **`USE_CRED_HELPERS`**: Use Docker credential helpers. Set to `"true"` or
  `"false"` as string a value. (_default:_ `"false"`)

* **`CACHE`**: The name of the persistent app cache volume (_default:_ an empty
  directory -- effectively no cache)

* **`USER_ID`**: The user ID of the builder image user, as a string value (_default:_ `"1000"`)

* **`GROUP_ID`**: The group ID of the builder image user, as a string value (_default:_ `"1000"`)

* **`SOURCE_SUBPATH`**: A subpath within the `source` input where the source to build is located (_default:_ `""`)

## Resources

### Outputs

* **`image`**: An `image`-type `PipelineResource` specifying the image that should
  be built.

## Workspaces

The `source` workspace holds the source that will be used by buildpack
to build and publish the container image.

## Usage

This `TaskRun` will use the `buildpacks-v3` task to build the source code, then publish a container image.

```
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: example-run
spec:
  taskRef:
    name: buildpacks-v3
# Uncomment the lines below to use an existing cache
#  podTemplate:
#    volumes:
#    - name: my-cache
#      persistentVolumeClaim:
#        claimName: task-pv-claim
  params:
  - name: SOURCE_SUBPATH
    value: <optional subpath within your source repo, e.g. "apps/java-maven">
  - name: BUILDER_IMAGE
    value: <your builder image tag, see below for suggestions, e.g. "builder-repo/builder-image:builder-tag">
# Uncomment the lines below to use an existing cache
#  - name: CACHE
#    value: my-cache
  resources:
    outputs:
    - name: image
      resourceSpec:
        type: image
        params:
        - name: url
          value: <your output image tag,
          e.g. "gcr.io/app-repo/app-image:app-tag">
  workspaces:
  - name: source
    persistentVolumeClaim:
      claimName: my-source
```

### Example builders

Cloud Foundry:
 - `cloudfoundry/cnb:bionic`
 - `cloudfoundry/cnb:cflinuxfs3`

Heroku:
 - `heroku/buildpacks:18`

## Previous Platform API Versions

Use one of the following commands to install a previous version of this task. Be sure to also supply a compatible builder image (`BUILDER_IMAGE` input) when running the task (i.e. one that has a lifecycle implementing the expected platform API).

### CNB Platform API 0.1

Commit: [5c2ab7d6](https://github.com/tektoncd/catalog/tree/5c2ab7d6c3b2507d43b49577d7f1bee9c49ed8ab/buildpacks#inputs)

```
kubectl -f https://github.com/tektoncd/catalog/blob/5c2ab7d6c3b2507d43b49577d7f1bee9c49ed8ab/buildpacks/buildpacks-v3.yaml
```
