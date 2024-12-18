# Buildpacks (phases)

**Note: this Task is only compatible with Tekton Pipelines versions 0.62.0 and greater!**

This task builds your runtime (Java, Node.js, ...) into a container image using [Cloud Native Buildpacks](https://buildpacks.io). To do that, it uses a [builder](https://buildpacks.io/docs/for-app-developers/concepts/builder/) to run [buildpacks](https://buildpacks.io/docs/for-app-developers/concepts/buildpack/) against the code source cloned.

> _**What are Cloud Native Buildpacks?**_
>
> _Cloud Native Buildpacks are pluggable, modular tools that transform application source code into OCI images. They replace Dockerfiles in the app development lifecycle, and enable for swift rebasing of images and modular control over images (through the use of builders), among other benefits._

The lifecycle phases are run in separate containers to enable better security for untrusted builders. Specifically, registry credentials are hidden from the detect and build phases of the [lifecycle](https://buildpacks.io/docs/for-platform-operators/concepts/lifecycle/), and the `analyze`, `restore`, and `export` phases (which require credentials) are run in the lifecycle image published by the [Cloud Native Buildpacks project]( https://hub.docker.com/u/buildpacksio).

## Compatibility

- **[Tekton][tekton-0.62]** v0.62.0 and above
- **[Platform API][platform-api-0.13]** 0.13

## Install

To play with this task, you will have to deploy Tekton (>= 0.62) on a Kubernetes cluster and this task:
```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/task/buildpacks-phases/0.3/buildpacks-phases.yaml
```

Next, create a `TaskRun` or `Pipeline(Run)` (see [usage](#usage)) where you set the mandatory `parameters` and `workspaces` as described hereafter:

## Parameters

- **`APP_IMAGE`**: The name of the container image for your application. _(REQUIRED)_
- **`SOURCE_SUBPATH`**: A subpath within the `source` input cloned where the source to build is located. _(optional, default: "")_
- **`USER_HOME`**: Absolute path to the user's home directory. _(default: `/tekton/home`)_
- **`TAGS`**: Additional tag to apply to the exported image. _(default: "")_

- **`CNB_BUILD_IMAGE`**: Reference to the build image to be used. If not provided, the task will use the CNB_BUILDER_IMAGE. _(optional, default: "")_
- **`CNB_BUILDER_IMAGE`**: The Builder image which includes the lifecycle tool, the buildpacks and metadata information like env vars, labels. _(REQUIRED)_
- **`CNB_CACHE_IMAGE`**: The name of the persistent app cache image (if no cache workspace is provided). _(optional, default: "")_
- **`CNB_ENV_VARS`**: `BP_*` environment variables to set during _build-time_. _(optional, default: [])_
- **`CNB_EXPERIMENTAL_MODE`**: Control the lifecycle's execution according to the mode silent, warn, error for the experimental features. _(optional, default: "silent")_
- **`CNB_GROUP_ID`**: The group ID of the builder image user. The value is extracted from the builder image when task runs _(optional, default: "")_
- **`CNB_INSECURE_REGISTRIES`**: List of registries separated by a comma having a self-signed certificate where TLS verification will be skipped. _(optional, default: "")_
- **`CNB_LAYERS_DIR`**: Path to the `layers` directory. _(optional, default: "/layers")_
- **`CNB_LOG_LEVEL`**: Logging level. Values available are: info, warning, error, debug. _(optional, default: "info")_
- **`CNB_PLATFORM_API`**: The Buildpack Platform API to be used. If not provided, the task will use the CNB_PLATFORM_API_SUPPORTED and compare it with the list of the APIs that lifecycle supports. _(optional, default: "")_
- **`CNB_PLATFORM_API_SUPPORTED`**. Buildpack Platform API supported by the Tekton task. _(default: "0.13")_
- **`CNB_PLATFORM_DIR`**: The name of the platform directory where env variables will be stored, etc. _(optional, default: "/platform")_
- **`CNB_PROCESS_TYPE`**: The default process type to set on the image. _(optional, default: "web")_
- **`CNB_RUN_IMAGE`**: Reference to the `run` image packaging the application runtime to be launched. _(optional, default: "")_
- **`CNB_SKIP_LAYERS`**: Do not restore SBOM layer from previous image. _(optional, default: "false")_
- **`CNB_USER_ID`**: The user ID of the builder image user. The value is extracted from the builder image when task runs _(optional, default: "")_

> Be sure to supply a compatible builder image (`CNB_BUILDER_IMAGE` input) when running this task (i.e. one that has a lifecycle that supports the CNB platform API).

| Platform API
|-----
| [0.13][platform-api-0.13]

## Results

* **APP_IMAGE_DIGEST**: The Digest of the image packaging the application.

## Workspaces

- **`source`**: Directory where application source is located. _(REQUIRED)_
- **`cache`**: Directory where cache is stored (when no cache image is provided). _(optional)_

## Usage

Use the following `Pipeline` and `PipelineRun` example (which also creates a PVC) to use this task and a runtime git project to be built

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: source-ws
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
---
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: my-buildpacks-pipeline
spec:
  workspaces:
    - name: source-ws
  tasks:
    - name: fetch-repository
      taskRef:
        resolver: git
        params:
          - name: url
            value: https://github.com/tektoncd/catalog.git
          - name: revision
            value: main
          - name: pathInRepo
            value: task/git-clone/0.10/git-clone.yaml
      workspaces:
        - name: output
          workspace: source-ws
      params:
        - name: url
          value: https://github.com/quarkusio/quarkus-quickstarts
        - name: subdirectory
          value: ""
        - name: deleteExisting
          value: "true"
    - name: buildpacks-phases
      taskRef:
        name: buildpacks-phases
      runAfter:
        - fetch-repository
      workspaces:
        - name: source
          workspace: source-ws
      params:
        - name: APP_IMAGE
          value: my-gitea-http.gitea.svc.cluster.local:3000/giteaadmin/buildpacks-app
        - name: SOURCE_SUBPATH
          value: getting-started
        - name: CNB_BUILDER_IMAGE
          value: paketobuildpacks/builder-ubi8-base:0.0.204@sha256:fbedab6060b4bb6c7bc695e43107469cec4f54da48cba752a9298b023b349ad5
        - name: CNB_INSECURE_REGISTRIES
          value: "my-gitea-http.gitea.svc.cluster.local:3000"
        - name: CNB_ENV_VARS
          value:
            - BP_JVM_VERSION=21
---
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  name: my-buildpacks--pipeline-run
spec:
  taskRunTemplate:
    serviceAccountName: sa-with-creds
  pipelineRef:
    name: my-buildpacks--pipeline
  workspaces:
    - name: source-ws
      persistentVolumeClaim:
        claimName: source-ws
```

**Important**: To use your `container registry` credentials (to bypass the docker hub limit, use your local container registry), it is needed to mount the credentials file in a kubernetes secret. This secret will be passed as parameter to the ServiceAccount's used by the Tekton task.

To let the TaskRun/PipelineRun to use it, set the `serviceAccount` parameter with the name of the serviceAccount.
When Tekton will run the task's pod, then it will mount the `.dockerconfigjson` under the following path: `/tekton/home/creds-secrets/<name_of_the_kubernetes_secret>/.dockerconfigjson`.

Here is an example where we create for the docker hub a secret:
```bash
kubectl create secret docker-registry dockercfg \
  --docker-server="https://index.docker.io/v1/" \
  --docker-username="<REGISTRY_USERNAME>" \
  --docker-password="<REGISTRY_PASSWORD>"

cat <<EOF | kubectl apply -f -
---  
apiVersion: v1
imagePullSecrets:
- name: dockercfg
kind: ServiceAccount
metadata:
  name: sa-with-secret
secrets:
- name: dockercfg
---
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: buildpacks-phases
spec:
  serviceAccountName: sa-with-secret
...  
```
**Note**: It is possible of course to use a docker `config.json` or podman `auth.json` combining several credentials; one per registry !

See the following additional samples too for usage:

- **[`bp-env-vars.yaml`](samples/bp-env-vars.yaml)**: A PipelineRun configured to provide _build-time_ environment variables. Example: `BP_JVM_VERSION=21`
- **[`cache.yaml`](samples/cache.yaml)**: A PipelineRun configured to demonstrate usage of the `cache` workspace.
- **[`results.yaml`](samples/results.yaml)**: A PipelineRun configured to demonstrate usage of task results.

## Platforms

The Task can be run on `linux/amd64` platform.

## Developer

The `skopeo-jq` container used part of this task can be (re)build using the `buildme` [script](containers/skopeo-jq/buildme). The existing image has been pushed on: `quay.io/halkyonio/skopeo-jq:0.1.0@sha256:6c85b38829b532a411783f75cf828192d7a5068a5470d8a49bca4ac5e6de5d88`

## Support

The [Buildpacks Community](http://buildpacks.io/community/) is always here to help.

We can be found in our [discussion board][discussion-board] or [slack][slack] (`#tekton`).

[discussion-board]: https://github.com/buildpacks/community/discussions
[CNCF Buildpacks slack channel]: https://cloud-native.slack.com/?redir=%2Fapp_redirect%3Fchannel%3Dbuildpacks

[platform-api-0.13]: https://github.com/buildpacks/spec/blob/platform/v0.13/platform.md
[tekton-0.62]: https://github.com/tektoncd/pipeline/releases/tag/v0.62.0