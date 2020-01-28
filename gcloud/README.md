# `gcloud`

This task performs operations on Google Cloud Platform resources using `gcloud`.

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/gcloud/gcloud.yaml
```

## Inputs

### Parameters

* **gcloud-image**: `gcloud` CLI container image to run this task.

  _default_: `google/cloud-sdk:slim`

  You can use a specific version of the `gcloud` CLI using
  `google/cloud-sdk:263.0.0-slim`.

  The default image (`:slim`) does not include any optional gcloud components.
  You can use an image with optional components installed by removing the `slim`
  (e.g., `google/cloud-sdk`, or `google/cloud-sdk:263.0.0`).

* **ARGS**: The arguments to pass to `gcloud` CLI.  _default_: `["help"]`

## Usage

### Authorizing `gcloud` commands

#### GKE Default Node Identity

On GKE, by default, [instance
metadata](https://cloud.google.com/compute/docs/storing-retrieving-metadata) is
available to workloads running in Pods, and this extends to Tekton TaskRuns.
This means that, by default, `gcloud` commands will be authorized as the
cluster's node identity, which is typically
`[PROJECT_NUMBER]-compute@developer.gserviceaccount.com`. You can specify this
account when creating or updating a GKE cluster.

#### GKE Workload Identity

Exposing node identity to all workloads on a cluster's nodes may not be what you
want.  For example, you might want certain workloads to operate under different
identities, or to not have authorization to perform actions at all.

To solve this, GKE allows cluster administrators to enable [Workload
Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity)
(beta), which ties a Kubernetes Service Account (KSA) on the cluster to a Google
IAM Service Account (GSA) on the cluster's project. With Workload Identity,
users can run TaskRuns as different KSAs, and have them be authorized as
different GSAs.

#### Outside GKE

To authorize `gcloud` as an IAM Service Account manually, or outside of GKE, you
can [download an IAM Service Account
Key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys)
and invoke [`gcloud auth
activate-service-account`](https://cloud.google.com/sdk/gcloud/reference/auth/activate-service-account)
within your workflow to authorize further `gcloud` commands as that IAM Service
Account.

### Running the Task

#### Checking authorization

You can invoke `gcloud auth list` to check that authorization is set up
correctly:

Create a file, `check-auth.yaml`:

```
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  generateName: auth-check-
spec:
  serviceAccountName: workload-identity-sa  # <-- a SA configured with Workload Identity
  taskRef:
    name: gcloud
  inputs:
    params:
    - name: ARGS
      value: ['auth', 'list']
```

Run it with `kubectl create -f check-auth.yaml`

When this runs, it will print logs indicating the Service Account it is using to
authorize its actions.

#### Deploying to Cloud Run

Create a file, `deploy-cloudrun.yaml`:

```
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  generateName: run-deploy
spec:
  serviceAccountName: workload-identity-sa  # <-- a SA configured with Workload Identity
  taskRef:
    name: gcloud
  inputs:
    params:
    - name: ARGS
      value:
      - run
      - deploy
      - my-service
      - --image=gcr.io/my-project/my-image
      - --platform=PLATFORM
      - --region=REGION
```

Run it with `kubectl create -f deploy-cloudrun.yaml`

When this runs, it will deploy the specified image as a new Revision to the
Cloud Run Service named `my-service`, running on the specified platform, in the
specified region.

#### Creating a GCE Instance

Create a file, `create-instance.yaml`:

```
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  generateName: run-deploy
spec:
  serviceAccountName: workload-identity-sa  # <-- a SA configured with Workload Identity
  taskRef:
    name: gcloud
  inputs:
    params:
    - name: ARGS
      value:
      - compute
      - instances
      - create
      - my-instance
      - --zone=ZONE
```

Run it with `kubect create -f create-instance.yaml`

When this runs, it will create a new GCE VM instance in the specified zone.
