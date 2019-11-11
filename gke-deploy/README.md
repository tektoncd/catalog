# `gke-deploy` `Task`

This Task deploys an application to a Google Kubernetes Engine cluster using [`gke-deploy`](https://github.com/GoogleCloudPlatform/cloud-builders/tree/master/gke-deploy).

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/gke-deploy/gke-deploy.yaml
```

## Inputs

### Resources

* **source-repo**: The Git source repository that contains your application's Kubernetes configs.

### Parameters

* **ARGS**: The arguments to pass to `gke-deploy` CLI.

  _default_: `["--help"]`

  See [here](https://github.com/GoogleCloudPlatform/cloud-builders/tree/master/gke-deploy#usage)
  for the arguments to `gke-deploy`.

## Usage

### Authorizing `gke-deploy` commands

See [Authorizing `gcloud`
commands](../gcloud/README.md#authorizing-gcloud-commands) for authorizing the
`gke-deploy` Task using a Google IAM Service Account (the instructions describe
authorizing `gcloud`, but the steps are the same).

In order for the `gke-deploy` Task to deploy to a GKE cluster in your project,
the service account that the Task runs as must have the
[`roles/container.developer`](https://cloud.google.com/iam/docs/understanding-roles#kubernetes-engine-roles) role, which can be achieved with the command below:

```bash
gcloud iam service-accounts [CLUSTER_PROJECT] add-iam-policy-binding \
  --role roles/container.developer\
  --member "serviceAccount:[SERVICE_ACCOUNT_EMAIL]"
```

### Running the Task

You can invoke `gke-deploy` to deploy manifests in a Git repository by
providing a TaskRun:

```yaml
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  name: gke-deploy-repo
spec:
  serviceAccountName: workload-identity-sa  # <-- a SA configured with Workload Identity
  taskRef:
    name: gke-deploy
  inputs:
    resources:
    - name: source-repo
      resourceSpec:
        type: git
        params:
        - name: url
          value: [GIT_REPO_URL]
        - name: revision
          value: [GIT_REPO_REVISION]
    params:
    - name: ARGS
      value:
      - run
      - --filename="$(inputs.resources.source-repo.path)/[PATH_TO_KUBERNETES_CONFIGS]"
      - --cluster=[CLUSTER_NAME]
      - --location=[CLUSTER_LOCATION]
      - --project=[CLUSTER_PROJECT]
```

See
[here](https://github.com/tektoncd/pipeline/blob/master/docs/resources.md#git-resource)
for more on how to use the Git Resource.

See
[here](https://github.com/tektoncd/pipeline/blob/master/docs/auth.md#ssh-authentication-git)
to learn how to access private Git repositories using Tekton.


# `build-push-gke-deploy` `Pipeline`

This Pipeline builds, pushes, and deploys your application to a Google Kubernetes Engine cluster using [`gke-deploy`](https://github.com/GoogleCloudPlatform/cloud-builders/tree/master/gke-deploy).

## Install the Pipeline

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/gke-deploy/build-push-gke-deploy.yaml
```

## Inputs

### Resources

* **source-repo**: The Git repository that contains your application's Dockerfile and Kubernetes configs.

### Parameters

* **pathToContext**: The path to the build context relative to your source repo's root. This is used by Kaniko.

  _default_: `.`

* **pathToDockerFile**: The path to the dockerfile to build, relative to the context.

  _default_: `Dockerfile`

* **pathToYamlConfigs**: The path to the Kubernetes configs to deploy, relative to your source repo's root.

* **imageUrl**: URL of image repository.

* **imageTag**: Tag to apply to the built image.

* **clusterName**: Name of target GKE cluster to deploy to.

* **clusterLocation**: Zone/region of target GKE cluster to deploy to.

* **clusterProject**: Project of target GKE cluster to deploy to.

  _default_: `""`

  If no value is provided, the target cluster is assumed to be in the same project as the cluster running this Pipeline.

## Usage

### Authorizing the Pipeline

See [Authorizing `gcloud`
commands](../gcloud/README.md#authorizing-gcloud-commands) for authorizing the
`build-push-gke-deploy` Pipeline using a Google IAM Service Account (the instructions will
describe authorizing `gcloud`, but the steps are the same).

In order for the `build-push-gke-deploy` Pipeline to push an image to your project, add the [`roles/storage.admin`](https://cloud.google.com/iam/docs/understanding-roles#storage-roles) role to the Google service account that the Pipeline runs as. This will allow the Pipeline to push an image to your project, as defined [here](https://cloud.google.com/container-registry/docs/access-control).

```bash
gcloud iam service-accounts [IMAGE_REGISTRY_PROJECT] add-iam-policy-binding \
  --role roles/storage.admin \
  --member "serviceAccount:[SERVICE_ACCOUNT_EMAIL]"
```

In order for the `build-push-gke-deploy` Pipeline to deploy to a GKE cluster in your project,
the service account that the Task runs as must have the
[`roles/container.developer`](https://cloud.google.com/iam/docs/understanding-roles#kubernetes-engine-roles) role.

```bash
gcloud iam service-accounts [DEPLOY_CLUSTER_PROJECT] add-iam-policy-binding \
  --role roles/container.developer \
  --member "serviceAccount:[SERVICE_ACCOUNT_EMAIL]"
```

### Running the Pipeline

You can invoke `build-push-gke-deploy` to build, push, and deploy your application in a Git repository to a GKE cluster by providing a PipelineRun:

```yaml
apiVersion: tekton.dev/v1alpha1
kind: PipelineRun
metadata:
  name: build-push-gke-deploy-run
spec:
  pipelineRef:
    name: build-push-gke-deploy
  serviceAccountName: workload-identity-sa  # <-- a SA configured with Workload Identity
  resources:
  - name: source-repo
    resourceSpec:
      type: git
      params:
      - name: url
        value: [GIT_REPO_URL]
      - name: revision
        value: [GIT_REPO_REVISION]
  params:
  - name: pathToContext
    value: [PATH_TO_CONTEXT]
  - name: pathToKubernetesConfigs
    value: [PATH_TO_KUBERNETES_CONFIGS]
  - name: [IMAGE_URL]
    value: gcr.io/cbd-test/test-app
  - name: imageTag
    value: [IMAGE_TAG]
  - name: clusterName
    value: [CLUSTER_NAME]
  - name: clusterLocation
    value: [CLUSTER_LOCATION]
  - name: clusterProject
    value: [CLUSTER_PROJECT]
```

See
[here](https://github.com/tektoncd/pipeline/blob/master/docs/resources.md#git-resource)
for more on how to use the Git Resource.

See
[here](https://github.com/tektoncd/pipeline/blob/master/docs/auth.md#ssh-authentication-git)
to learn how to access private Git repositories in Tekton.

See
[here](build-push-gke-deploy-example.md) for a full example of using this Pipeline.
