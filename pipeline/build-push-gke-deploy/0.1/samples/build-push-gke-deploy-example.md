# Build, push, and deploy with the `build-push-gke-deploy` Pipeline Example

This guide walks through a detailed example that demonstrates using the `build-push-gke-deploy` Pipeline to build, push, and deploy an application in a Git repository to a GKE cluster.

## Set up your Tekton cluster, Google service account, and Kubernetes service account

1. Follow the instructions [here](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity#enable_workload_identity_on_a_new_cluster) to create a new GKE cluster with Workload Identity enabled, create a Google service account, and create a Kubernetes service account for your Pipeline that binds to the Google service account.

1. Follow the instructions [here](https://github.com/tektoncd/pipeline/blob/main/docs/install.md#installing-tekton-pipelines-1) to install Tekton Pipelines onto your cluster.

  Alternatively, set the variables below and run the script to automate the above steps.

  ```bash
  TEKTON_CLUSTER_NAME=[NAME]
  TEKTON_CLUSTER_LOCATION=[REGION/ZONE]
  TEKTON_CLUSTER_PROJECT=[PROJECT_ID]
  K8S_SA_NAME=[KUBERNETES_SERVICE_ACCOUNT_NAME]
  GOOGLE_SA_NAME=[GOOGLE_SERVICE_ACCOUNT_NAME]

  # Create a GKE cluster with Workload Identity enabled
  gcloud beta container clusters create $TEKTON_CLUSTER_NAME \
    --zone=$TEKTON_CLUSTER_LOCATION \
    --project=$TEKTON_CLUSTER_PROJECT \
    --identity-namespace=$TEKTON_CLUSTER_PROJECT.svc.id.goog

  # Configure kubectl to communicate with the cluster
  gcloud container clusters get-credentials $TEKTON_CLUSTER_NAME \
    --zone=$TEKTON_CLUSTER_LOCATION \
    --project=$TEKTON_CLUSTER_PROJECT

  # Create the Kubernetes service account that your TaskRun will run as
  kubectl create serviceaccount $K8S_SA_NAME

  # Create the Google service account that the Kubernetes service account will bind to
  gcloud iam service-accounts create $GOOGLE_SA_NAME --project=$TEKTON_CLUSTER_PROJECT

  # Bind the Google service account and Kubernetes service account.
  gcloud iam service-accounts add-iam-policy-binding \
    --role roles/iam.workloadIdentityUser \
    --project=$TEKTON_CLUSTER_PROJECT \
    --member "serviceAccount:$TEKTON_CLUSTER_PROJECT.svc.id.goog[default/$K8S_SA_NAME]" $GOOGLE_SA_NAME@$TEKTON_CLUSTER_PROJECT.iam.gserviceaccount.com
  kubectl annotate serviceaccount $K8S_SA_NAME iam.gke.io/gcp-service-account=$GOOGLE_SA_NAME@$TEKTON_CLUSTER_PROJECT.iam.gserviceaccount.com

  # Install Tekton Pipelines
  kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
  ```

## Install Tekton Pipelines CLI

Install the Tekton Pipelines CLI to view your logs by following the instructions for your machine at <https://github.com/tektoncd/cli>.

## Set up your repo

1. Fork and clone this [GitHub repo](https://github.com/tektoncd/catalog). See [here](https://help.github.com/en/github/getting-started-with-github/fork-a-repo) for more information on forking a repo.

2. Clone the forked repo onto your local machine and cd into the directory.

  ```bash
  GITHUB_USER=[YOUR_USERNAME]
  git clone https://github.com/$GITHUB_USER/catalog
  # Use `git clone git@github.com:$GITHUB_USER/catalog.git` if you use two-factor authentication
  cd catalog
  ```

3. Modify the manifests in the demo app to use a project you own for its image (this may be the same project as the one with the cluster that is running Tekton Pipelines).

  ```bash
  IMAGE_REGISTRY_PROJECT=[PROJECT_ID]
  sed -i "s/@IMAGE_REGISTRY_PROJECT@/$IMAGE_REGISTRY_PROJECT/g" pipeline/build-push-gke-deploy/0.1/samples/app/config/app.yaml
  ```

4. Commit and push your changes to a new branch.

  ```bash
  git checkout -b gke-deploy-demo
  git commit -a -m "Set gke-deploy demo image project name."
  git push
  ```

## Run Pipeline

1. Create the target cluster that gke-deploy will deploy your application to.

  ```bash
  DEPLOY_CLUSTER_NAME=[NAME]
  DEPLOY_CLUSTER_LOCATION=[REGION/ZONE]
  DEPLOY_CLUSTER_PROJECT=[PROJECT_ID]
  gcloud container clusters create $DEPLOY_CLUSTER_NAME --zone=$DEPLOY_CLUSTER_LOCATION --project=$DEPLOY_CLUSTER_PROJECT
  ```

2. Add the `roles/storage.admin` role to the Google service account set up above in the project that the image will be pushed to (this may be the same project as the one with the cluster that is running Tekton Pipelines). This will allow the Pipeline to push an image to your project, as defined [here](https://cloud.google.com/container-registry/docs/access-control).

  ```bash
  IMAGE_REGISTRY_PROJECT=[PROJECT_ID]
  GOOGLE_SA_NAME=[GOOGLE_SERVICE_ACCOUNT_NAME]
  TEKTON_CLUSTER_PROJECT=[PROJECT_ID]
  gcloud projects add-iam-policy-binding $IMAGE_REGISTRY_PROJECT --role roles/storage.admin --member "serviceAccount:$GOOGLE_SA_NAME@$TEKTON_CLUSTER_PROJECT.iam.gserviceaccount.com" --project=$IMAGE_REGISTRY_PROJECT
  ```

3. Add the `roles/container.developer` role to the Google service account set up above in the project of the target cluster (this may be the same project as the one with the cluster that is running Tekton Pipelines). This will allow the Pipeline to deploy your application to your cluster.

  ```bash
  DEPLOY_CLUSTER_PROJECT=[PROJECT_ID]
  GOOGLE_SA_NAME=[GOOGLE_SERVICE_ACCOUNT_NAME]
  TEKTON_CLUSTER_PROJECT=[PROJECT_ID]
  gcloud projects add-iam-policy-binding $DEPLOY_CLUSTER_PROJECT --role roles/container.developer --member "serviceAccount:$GOOGLE_SA_NAME@$TEKTON_CLUSTER_PROJECT.iam.gserviceaccount.com" --project=$DEPLOY_CLUSTER_PROJECT
  ```

4. Install the `build-push-gke-deploy` Pipeline.

  ```bash
  kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/pipeline/build-push-gke-deploy/0.1/raw
  ```

5. Create the `PipelineRun` config to run your Pipeline.

  ```bash
  K8S_SA_NAME=[KUBERNETES_SERVICE_ACCOUNT_NAME]
  GITHUB_USER=[YOUR_USERNAME]
  IMAGE_REGISTRY_PROJECT=[PROJECT_ID]
  DEPLOY_CLUSTER_NAME=[NAME]
  DEPLOY_CLUSTER_LOCATION=[REGION/ZONE]
  DEPLOY_CLUSTER_PROJECT=[PROJECT_ID]

  cat >build-push-gke-deploy-run.yaml <<EOF
  apiVersion: tekton.dev/v1beta1
  kind: PipelineRun
  metadata:
    name: build-push-gke-deploy-run
  spec:
    pipelineRef:
      name: build-push-gke-deploy
    serviceAccountName: $K8S_SA_NAME
    resources:
    - name: source-repo
      resourceSpec:
        type: git
        params:
        - name: url
          value: https://github.com/$GITHUB_USER/catalog
        - name: revision
          value: gke-deploy-demo
    params:
    - name: pathToContext
      value: gke-deploy/example/app
    - name: pathToKubernetesConfigs
      value: gke-deploy/example/app/config
    - name: imageUrl
      value: gcr.io/$IMAGE_REGISTRY_PROJECT/gke-deploy-tekton-demo
    - name: imageTag
      value: 1.0.0
    - name: clusterName
      value: $DEPLOY_CLUSTER_NAME
    - name: clusterLocation
      value: $DEPLOY_CLUSTER_LOCATION
    - name: clusterProject
      value: $DEPLOY_CLUSTER_PROJECT
  EOF

  kubectl apply -f build-push-gke-deploy-run.yaml
  ```

6. Watch the logs.

  ```bash
  tkn pipelinerun logs build-push-gke-deploy-run --follow
  ```

  See other ways of logging your Tekton PipelineRun [here](https://github.com/tektoncd/pipeline/blob/main/docs/logs.md).

  If your deployment is successful, `gke-deploy` will print a table displaying deployed resources. You can visit the IP address printed on the Service row.

  e.g.,

  ![deployed-resources](deployed-resources.png)

  ![response](response.png)

## Cleaning up

You may want to clean up created resources that incur charges on your Google Cloud Platform account.

1. Delete the image from your registry:

  ```bash
  gcloud container images delete gcr.io/$IMAGE_REGISTRY_PROJECT/gke-deploy-tekton-demo:1.0.0
  ```

2. Delete the IAM policy bindings on your Google service account:

  ```bash
  TEKTON_CLUSTER_PROJECT=[PROJECT_ID]
  GOOGLE_SA_NAME=[GOOGLE_SERVICE_ACCOUNT_NAME]
  IMAGE_REGISTRY_PROJECT=[PROJECT_ID]
  DEPLOY_CLUSTER_PROJECT=[PROJECT_ID]
  gcloud projects remove-iam-policy-binding $IMAGE_REGISTRY_PROJECT --member=serviceAccount:$GOOGLE_SA_NAME@$TEKTON_CLUSTER_PROJECT.iam.gserviceaccount.com --role=roles/storage.admin --project=$IMAGE_REGISTRY_PROJECT
  gcloud projects remove-iam-policy-binding $DEPLOY_CLUSTER_PROJECT --member=serviceAccount:$GOOGLE_SA_NAME@$TEKTON_CLUSTER_PROJECT.iam.gserviceaccount.com --role=roles/container.developer --project=$DEPLOY_CLUSTER_PROJECT
  ```

3. Delete the Google service account:

  ```bash
  TEKTON_CLUSTER_PROJECT=[PROJECT_ID]
  GOOGLE_SA_NAME=[GOOGLE_SERVICE_ACCOUNT_NAME]
  gcloud iam service-accounts delete $GOOGLE_SA_NAME@$TEKTON_CLUSTER_PROJECT.iam.gserviceaccount.com --project=$TEKTON_CLUSTER_PROJECT -q
  ```

4. Delete your clusters:

  ```bash
  TEKTON_CLUSTER_NAME=[NAME]
  TEKTON_CLUSTER_LOCATION=[REGION/ZONE]
  TEKTON_CLUSTER_PROJECT=[PROJECT_ID]
  gcloud container clusters delete $TEKTON_CLUSTER_NAME --zone=$TEKTON_CLUSTER_LOCATION --project=$TEKTON_CLUSTER_PROJECT --async -q

  DEPLOY_CLUSTER_NAME=[NAME]
  DEPLOY_CLUSTER_LOCATION=[REGION/ZONE]
  DEPLOY_CLUSTER_PROJECT=[PROJECT_ID]
  gcloud container clusters delete $DEPLOY_CLUSTER_NAME --zone=$DEPLOY_CLUSTER_LOCATION --project=$DEPLOY_CLUSTER_PROJECT --async -q
  ```
