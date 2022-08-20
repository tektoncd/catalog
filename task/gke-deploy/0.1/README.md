  # `gke-deploy` `Task`

This Task deploys an application to a Google Kubernetes Engine cluster using [`gke-deploy`](https://github.com/GoogleCloudPlatform/cloud-builders/tree/master/gke-deploy).

## Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/gke-deploy/0.1/raw
```

## Parameters

* **ARGS**: The arguments to pass to `gke-deploy` CLI.

  _default_: `["--help"]`

  See [here](https://github.com/GoogleCloudPlatform/cloud-builders/tree/master/gke-deploy#usage)
  for the arguments to `gke-deploy`.

## Workspaces

* **source**: The Git source repository that contains your application's Kubernetes configs.

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

### Authorizing `gke-deploy` commands

See [Authorizing `gcloud`
commands](../../gcloud/0.1/README.md#authorizing-gcloud-commands) for authorizing the
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
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: gke-deploy-repo
spec:
  serviceAccountName: workload-identity-sa  # <-- a SA configured with Workload Identity
  taskRef:
    name: gke-deploy
  workspaces:
  - name: source
    persistentVolumeClaim:
      claimName: my-source
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
[here](https://github.com/tektoncd/pipeline/blob/main/docs/resources.md#git-resource)
for more on how to use the Git Resource.

See
[here](https://github.com/tektoncd/pipeline/blob/main/docs/auth.md#ssh-authentication-git)
to learn how to access private Git repositories using Tekton.
