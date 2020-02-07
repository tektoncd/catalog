# Git Source with Dockerfile to Knative Service

This documents the example Pipeline to build the source code with a Dockerfile in
the git repo and deploy it as Knative Service.
It uses [buildah task](../../buildah/README.md) for building the source code and
[kn task](../README.md) to create or update a Knative Service.

## Prerequisites:

1. Latest Tekton Pipelines [install](https://github.com/tektoncd/pipeline/blob/master/docs/install.md)ed.
2. `kubectl` CLI [install](https://kubernetes.io/docs/tasks/tools/install-kubectl/)ed.
3. `tkn` CLI [install](https://github.com/tektoncd/cli#installing-tkn)ed.
4. User account exists at a container registry (e.g. [quay.io](https://quay.io))
5. A ServiceAccount to enable access to perform the required operations in the Pipeline,
   we'll configure one in following section.

### One time setup:

1 - Create a sample namespace `tkn-kn`, we'll reference this namespace in the subsequent operations.
```bash
kubectl create namespace tkn-kn
```

2 - Create a `docker-registry` type secrets for pushing/pulling the built container images.
```bash
kubectl create secret docker-registry container-registry --docker-server=<DOCKER-REGISTRY> --docker-username=<USERNAME> --docker-password=<PASSWORD> --docker-email=<EMAIL>
```
More about secrets for [`interacting with a private registry`](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/).

#### Note:
- For using `docker.io`: Please [create a new](https://hub.docker.com/repository/create) empty public repository and refer it in subsequent steps.
- For using `quay.io`: No need to create a repository beforehand.

3 - Create a ServiceAccount `kn-deployer-account` and
 - link `container-registry` secret created above in step 2
 - create cluster role `kn-deployer` to access the Knative resources
 - binds the ServiceAccount with cluster role `kn-deployer` in namespace `tkn-kn`
 - Save following YAML in e.g. `kn_deployer.yaml` and apply using `kubectl apply -f kn_deployer.yaml`.

```yaml
# Define a ServiceAccount named kn-deployer-account that has permission to
# manage Knative services.
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kn-deployer-account
  namespace: tkn-kn
# Link the container registry secrets
secrets:
  - name: container-registry
# To be able to pull the (private) image from the container registry
imagePullSecrets:
  - name: container-registry
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: kn-deployer
rules:
  - apiGroups: ["serving.knative.dev"]
    resources: ["services"]
    verbs: ["get", "list", "create", "update", "delete", "patch", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: kn-deployer-binding
subjects:
- kind: ServiceAccount
  name: kn-deployer-account
  namespace: tkn-kn
roleRef:
  kind: ClusterRole
  name: kn-deployer
  apiGroup: rbac.authorization.k8s.io
```

  - If you've used the same names for namespace and secrets as mentioned above, you can configure the ServiceAccount with the YAML file in this repo using:
```bash
kubectl create -f https://raw.githubusercontent.com/tektoncd/catalog/master/kn/knative-dockerfile-deploy/kn_deployer.yaml
```

4 - Install buildah task from tektoncd/atalog
```bash
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/buildah/buildah.yaml
```

5 - Install the kn task from the tektoncd/atalog
```bash
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/kn/kn.yaml
```

## Pipelines:

Let's create some Pipelines using `buildah` and `kn` tasks:
1. Create an image from git source and deploy to the Knative Service [pipeline](./build_deploy/README.md)
2. Deploy a new Revision to the Knative Service [pipeline](./service_update/README.md)
3. Perform traffic operations on the Knative Service [pipeline](./service_traffic/README.md)
