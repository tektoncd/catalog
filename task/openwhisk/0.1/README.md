# OpenWhisk Runtimes for Knative

This directory contains Tekton Task which can be used to Build and Serve Knative compatible applications (i.e., OpenWhisk Actions) on Kubernetes.

## Pre-requisites

The general pre-requisites are as follows:
- [x] Kubernetes v1.14.3
- [x] kubectl
- [x] Knative v0.5.0
- [x] Tekton Pipeline
- [x] Knative Client (OPTIONAL)

Specifically, for development and testing on Mac OS, the following components and versions were used:

- [x] [Docker Desktop for Mac Docker Community Edition 2.0.5.0 2019-06-11](https://docs.docker.com/docker-for-mac/edge-release-notes/) which includes:
    - Docker 19.03.0
    - Kubernetes 1.14.3
- [x] [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (```brew install kubernetes-cli```)
- [x] [Knative 0.5.0](https://github.com/knative/serving/releases/tag/v0.5.0) (which will install and configure istio-1.0.7 compatible resources)
- [x] [Tekton Pipeline](https://github.com/tektoncd/pipeline/blob/master/docs/install.md#adding-the-tekton-pipelines)
- [x] [Knative Client](https://storage.cloud.google.com/knative-nightly/client/latest/kn-darwin-amd64) (```mv client_latest_kn-darwin-amd64 /usr/local/bin/kn && chmod +x /usr/local/bin/kn```)

### Docker Desktop Minimum Configuration

Under the Docker Desktop menu select "**Preferences**"->"**Advanced**" and set these values to at least these minimums:
- [x] **CPUs: 4**
- [x] **Memory: 8.0 GiB**
- [x] **Swap: 1.0 GiB**

Under the Docker Desktop **Kubernetes** tab, please assure that Kubernetes is **enabled** and running.

### Verify Kubernetes Installation

Use the following command to verify the Kubernetes **Server Version** indicates version 1.14:

```bash
$ kubectl version

Client Version: version.Info{Major:"1", Minor:"14", GitVersion:"v1.14.3", GitCommit:"5e53fd6bc17c0dec8434817e69b04a25d8ae0ff0", GitTreeState:"clean", BuildDate:"2019-06-06T01:44:30Z", GoVersion:"go1.12.5", Compiler:"gc", Platform:"darwin/amd64"}
Server Version: version.Info{Major:"1", Minor:"14", GitVersion:"v1.14.3", GitCommit:"5e53fd6bc17c0dec8434817e69b04a25d8ae0ff0", GitTreeState:"clean", BuildDate:"2019-06-06T01:36:19Z", GoVersion:"go1.12.5", Compiler:"gc", Platform:"linux/amd64"}
```

The ```Server Version``` is the version for the Kubernetes service; the ```Client Version``` is for the Kubernetes CLI (i.e., ```kubectl```).

#### Verify you have a Kubernetes v1.14.0 node ready
```
$ kubectl get nodes

NAME             STATUS    ROLES     AGE       VERSION
docker-desktop   Ready     master    4d22h     v1.14.3
```

#### Verify all Kubernetes pods are running

```
$ kubectl get pods --namespace kube-system
```
<details>
    <summary>Sample output</summary>

```
NAME                                     READY     STATUS    RESTARTS   AGE
coredns-86c58d9df4-ms8qs                 1/1       Running   0          4d22h
coredns-86c58d9df4-x29vt                 1/1       Running   0          4d22h
etcd-docker-desktop                      1/1       Running   1          4d22h
kube-apiserver-docker-desktop            1/1       Running   1          4d22h
kube-controller-manager-docker-desktop   1/1       Running   3          4d22h
kube-proxy-mltsm                         1/1       Running   0          4d22h
kube-scheduler-docker-desktop            1/1       Running   3          4d22h
```
</details>

## Knative Install on a Kubernetes Cluster

The following instructions were used to install Knative: [Knative Install on a Kubernetes Cluster](https://knative.dev/v0.5-docs/install/knative-with-minikube/)

**Note:** These instructions include instatlling Knative with Istio, other possibilities of Ingress/Gateway selection is listed [here](https://knative.dev/v0.5-docs/install/index.html).

These instructions take you through the installation of
- [x] [Istio v1.0.7](https://github.com/istio/istio/releases) using resources specifically configured for use with Knative Serving.
- [x] [Knative v0.5.0](https://github.com/knative/serving/releases/tag/v0.5.0)

## Verify Knative installation

#### Verify Istio pods are running

```bash
$ kubectl get pods --namespace istio-system
```
<details>
    <summary>Sample output</summary>

```
NAME                                       READY     STATUS      RESTARTS   AGE
cluster-local-gateway-547467ccf6-p8n72     1/1       Running     1          4d21h
istio-citadel-7d64db8bcf-m7gsj             1/1       Running     0          4d21h
istio-cleanup-secrets-8lzj4                0/1       Completed   0          4d21h
istio-egressgateway-6ddf4c8bd6-2dxhc       1/1       Running     1          4d21h
istio-galley-7dd996474-pdd6h               1/1       Running     1          4d21h
istio-ingressgateway-84b89d647f-cxrwx      1/1       Running     1          4d21h
istio-pilot-86bb4fcbbd-5ns5q               2/2       Running     0          4d21h
istio-pilot-86bb4fcbbd-vd2xr               2/2       Running     0          4d21h
istio-pilot-86bb4fcbbd-zstrw               2/2       Running     0          4d21h
istio-policy-5c4d9ff96b-559db              2/2       Running     1          4d21h
istio-security-post-install-dv8s7          0/1       Completed   0          4d21h
istio-sidecar-injector-6977b5cf5b-94hj5    1/1       Running     0          4d21h
istio-telemetry-7676df547f-jp952           2/2       Running     1          4d21h
zipkin-8594bbfc6b-z6vdg                    1/1       Running     1          4d21h  
```
</details>

#### Verify your default namespace uses Istio for all services

Check the `default` namespace has the label **istio-injection** and it is set to **enabled**:

```bash
$ kubectl get namespace default -o yaml
```

Example output:
```
apiVersion: v1
kind: Namespace
metadata:
  creationTimestamp: "2019-06-13T16:52:46Z"
  labels:
    istio-injection: enabled
  name: default
  resourceVersion: "18019"
  selfLink: /api/v1/namespaces/default
  uid: ab987afe-8dfb-11e9-8092-025000000001
spec:
  finalizers:
  - kubernetes
status:
  phase: Active
```

**Note**: If you do not see the **istio-injection** label, verify you issued the 'kubectl' command to set this label to the default namespace. See [Troubleshooting](#troubleshooting) section for more information.

# Building and Serving OpenWhisk Runtime Tekton Task 

All OpenWhisk Runtime Tekton Task require a valid Kubernetes **Service Account** with access to a Kubernetes **Secret** that contains your username and password to image resgistry.  This credential will be used as part of the Tekton build process to "push" your Knative application image containing your OpenWhisk Action to image resgistry of your choice.

## Clone this repository

```bash
$ git clone https://github.com/tektoncd/catalog.git
$ cd openwhisk
```

## Register Secrets for Docker Hub

Export your Docker Hub **username** and **password** required to register a new secret in Kubernetes.

```
$ export DOCKER_USERNAME=<your docker hub username>
$ export DOCKER_PASSWORD=<your docker hub password>
```

Use the following `sed` command which will generate a `docker-secret.yaml` file from the file [docker-secret.yaml.tmpl](docker-secret.yaml.tmpl) and replace the **username** and **password** values with your Docker Hub username and password from the environment variables you exported above:

```
sed -e 's/${DOCKER_USERNAME}/'"$DOCKER_USERNAME"'/' -e 's/${DOCKER_PASSWORD}/'"$DOCKER_PASSWORD"'/' docker-secret.yaml.tmpl > docker-secret.yaml
```

Apply the Secret resource manifest for Docker Hub:

```bash
$ kubectl apply -f docker-secret.yaml
secret/dockerhub-user-pass created
```

Verify Secret exists:

```bash
$ kubectl get secret
NAME                    TYPE                                  DATA      AGE
dockerhub-user-pass     kubernetes.io/basic-auth              2         21s
```

## Create Service Account for our Runtime Builds

Tekton requires a valid ServiceAccount resource that will be used when building and serving OpenWhisk Serverless Actions using the OpenWhisk runtimes. For convenience, all runtime builds are configured to use the same ServiceAccount as defined in [service-account.yaml](service-account.yaml).

```bash
$ kubectl apply -f service-account.yaml
serviceaccount/openwhisk-runtime-builder created
```

Verify the Service account has 2 secrets (i.e., username and password):

```
$ kubectl get serviceaccount/openwhisk-runtime-builder
NAME                        SECRETS   AGE
openwhisk-runtime-builder   2         3m46s
```

## Create Tekton Task to Define Runtime Inputs/Parameters/Output

Tekton task defines end-to-end workflow to pull OpenWhisk runtime specified in input section, build it with action code injected in the runtime, and push the image to remote registry specified in the output. Tekton task consists of a number of steps to execute this workflow.

```bash
$ kubectl apply -f openwhisk.yaml
task.tekton.dev/openwhisk created
```

## Building OpenWhisk Runtimes and Executing Functions

At this point, you have completed all the pre-reqs to build and run OpenWhisk runtimes using Tekton. In order to actually build and run them, you will need to continue following the instructions on the READMEs for the respective language runtimes listed below:
- [NodeJS Runtime](./runtimes/javascript/#OpenWhisk-NodeJS-Runtime-for-Knative)

---

## Troubleshooting

### Knative and Istio Install

#### PROBLEM: Kubernetes default namespace does not have "istio-injection: enabled" key-value

If the `default` namespace does not have this value under the `metadata` section, you may have forgotton to issue the following command as part of the Knative setup:

```bash
$ kubectl label namespace default istio-injection=enabled
namespace "default" labeled
```

#### PROBLEM: Kubernetes and Istio resources do not all say "created" on "apply"

1. Verify that you have configured Docker Desktop to have the required CPU and Memory values recommended above.
2. Verify that all resources installed by applying either tha Knative or Istio YAML files show **"created"** during the installation.
- If any of your resources were NOT **created**, then we recommend uninstalling Knative and Istio and trying again until you get the **created** result for all resources WITHOUT trying to apply a second time. Below is an example of successful creation of Knative resources:

<p>
    <details>
    <summary>Sample output: Successful Knative resources creation</summary>

```
clusterrole "knative-build-admin" created
serviceaccount "build-controller" created
clusterrolebinding "build-controller-admin" created
customresourcedefinition "builds.build.knative.dev" created
customresourcedefinition "buildtemplates.build.knative.dev" created
customresourcedefinition "clusterbuildtemplates.build.knative.dev" created
customresourcedefinition "images.caching.internal.knative.dev" created
service "build-controller" created
service "build-webhook" created
image "creds-init" created
image "git-init" created
...
rolebinding "prometheus-system" created
rolebinding "prometheus-system" created
rolebinding "prometheus-system" created
rolebinding "prometheus-system" created
clusterrolebinding "prometheus-system" created
service "prometheus-system-np" created
statefulset "prometheus-system" created
```
</details>
</p>

