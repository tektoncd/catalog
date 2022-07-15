
# `build-push-gke-deploy` `Pipeline`

This Pipeline builds, pushes, and deploys your application to a Google Kubernetes Engine cluster using [`gke-deploy`](https://github.com/GoogleCloudPlatform/cloud-builders/tree/master/gke-deploy).

## Install the task

Both `Kaniko` and `Gke-deploy` tasks have been used from tekton catalog

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/kaniko/0.2/raw
```

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/gke-deploy/0.1/raw
```

## Install the Pipeline

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/pipeline/build-push-gke-deploy/0.1/raw
```

## Workspaces

* **source**: The Git repository that contains your application's Dockerfile and Kubernetes configs.

## Parameters

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

## Platforms

The Pipeline can be run on `linux/amd64` platform.

## Usage

### Authorizing the Pipeline

See [Authorizing `gcloud`
commands](../../build-push-gke-deploy/0.1/README.md#authorizing-gcloud-commands) for authorizing the
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
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: build-push-gke-deploy-run
spec:
  pipelineRef:
    name: build-push-gke-deploy
  serviceAccountName: workload-identity-sa  # <-- a SA configured with Workload Identity
  workspaces:
  - name: source
    persistentVolumeClaim:
      claimName: my-source
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
[here](https://github.com/tektoncd/pipeline/blob/main/docs/resources.md#git-resource)
for more on how to use the Git Resource.

See
[here](https://github.com/tektoncd/pipeline/blob/main/docs/auth.md#ssh-authentication-git)
to learn how to access private Git repositories in Tekton.

See
[here](../0.1/samples/build-push-gke-deploy-example.md) for a full example of using this Pipeline.
