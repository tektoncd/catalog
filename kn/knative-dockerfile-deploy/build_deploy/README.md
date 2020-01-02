# Build and Deploy Pipeline

Let's create a container image from a git source having a Dockerfile and deploy it to a Knative Service.
This Pipeline builds and push the git source using `buildah` and deploys the container as Knative Service using `kn`.

## Pipeline:

The following Pipeline definition refers:
 - `buildah` and `kn` tasks (we've installed these tasks in One time Setup section)
- Pipeline resources for git and resulting container image repository
- Save the following YAML in a file e.g.: `build_deploy_pipeline.yaml` and create the Pipeline using
  `kubectl create -f build_deploy_pipeline.yaml`

```yaml
apiVersion: tekton.dev/v1alpha1
kind: Pipeline
metadata:
  name: buildah-build-kn-create
spec:
  resources:
  - name: source
    type: git
  - name: image
    type: image
  params:
  - name: ARGS
    type: array
    description: Arguments to pass to kn CLI
    default:
      - "help"
  tasks:
  - name: buildah-build
    taskRef:
      name: buildah
    resources:
      inputs:
        - name: source
          resource: source
      outputs:
        - name: image
          resource: image
  - name: kn-service-create
    taskRef:
      name: kn
    runAfter:
      - buildah-build
    resources:
      inputs:
      - name: image
        resource: image
        from:
          - buildah-build
    params:
    - name: kn-image
      value: "gcr.io/knative-nightly/knative.dev/client/cmd/kn"
    - name: ARGS
      value:
        - "$(params.ARGS)"
```

 - You can also create this Pipeline using the YAML file present in this repo using
```
kubectl create -f https://raw.githubusercontent.com/tektoncd/catalog/master/kn/knative-dockerfile-deploy/build_deploy/build_deploy_pipeline.yaml
```
## PipelineResource

Let's create Pipeline resources that we've referenced in the above Pipeline.

### Note:
 - Make sure the git repository has a Dockerfile at root of the repo.
 - Make sure the container repository URL is correct and you have push access to.
 - If you are using docker.io container registry, please [create a new](https://hub.docker.com/repository/create) empty repository in advance.

Save the following YAML for Pipeline resources in a file e.g.: `resources.yaml` and make sure to update the values for the git and container repositories.
Create the resource as `kubectl create -f resources.yaml`.

```yaml
apiVersion: tekton.dev/v1alpha1
kind: PipelineResource
metadata:
  name: buildah-build-kn-create-source
spec:
  type: git
  params:
    - name: url
      value: "https://github.com/navidshaikh/helloworld-go"
---
apiVersion: tekton.dev/v1alpha1
kind: PipelineResource
metadata:
  name: buildah-build-kn-create-image
spec:
  type: image
  params:
    - name: url
      value: "quay.io/navidshaikh/helloworld-go"
```

## PipelineRun:

- Let's trigger the Pipeline we've created above referncing the resources via PipelineRun.
- Note that we've referenced ServiceAccount `kn-deployer-account` in `kn` CLI arguments,
  it tells `kn` which ServiceAccount to use while pulling the image from (private) container registry.
- Also note that, we're giving creating service namely `hello` and asking to create Revision
  `hello-v1`, we'll use this Revision name in subsequent Pipeline operations.

Save the following YAML in a file e.g.: `pipeline_run.yaml` and create PipelineRun as
`kubectl create -f pipeline_run.yaml`.

```yaml
apiVersion: tekton.dev/v1alpha1
kind: PipelineRun
metadata:
  generateName: buildah-build-kn-create-
spec:
  serviceAccountName: kn-deployer-account
  pipelineRef:
    name: buildah-build-kn-create
  resources:
    - name: source
      resourceRef:
        name: buildah-build-kn-create-source
    - name: image
      resourceRef:
        name: buildah-build-kn-create-image
  params:
    - name: ARGS
      value:
        - "service"
        - "create"
        - "hello"
        - "--revision-name=hello-v1"
        - "--image=$(inputs.resources.image.url)"
        - "--env=TARGET=Tekton"
        - "--service-account=kn-deployer-account"
```

 - You can also create this PipelineRun using the YAML file present in this repo using
```
kubectl create -f https://raw.githubusercontent.com/tektoncd/catalog/master/kn/knative-dockerfile-deploy/build_deploy/pipeline_run.yaml
```

- We can monitor the logs of this PipelineRun using `tkn` CLI
```bash
tkn pr list
tkn pr logs <pipelinerun-name> logs -f
```

- After the successful PipelineRun, we should have the source built, pushed to the repo and deployed as Knative Service. Let's check it:

```bash
kubectl get ksvc hello
```

## What's Next:
- We've built a container image from git source, pushed it to a container registry, deployed a Knative Service using the image.
- You can use other available `kn` options to configure the Service, just add them to `params.ARGS` field in above `pipeline_run.yaml`. Check the list of supported options in `kn` [here](https://github.com/knative/client/blob/master/docs/cmd/kn.md).
- We've further pipeline examples showing [service update](../service_update/README.md) and [service traffic](../service_traffic/README.md) operations.
