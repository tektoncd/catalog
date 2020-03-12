## OpenShift Image Streams

[OpenShift](http://www.openshift.com) is a Kubernetes distribution from Red Hat. 

It provides some extensions to Kubernetes, some of which can assist with development and CI/CD flows.

One such extension is the [`ImageStream` concept](https://docs.okd.io/latest/openshift_images/images-understand.html)
and the associated [built in or "internal" container image registry](https://docs.okd.io/latest/registry/architecture-component-imageregistry.html)
which facilitates the `ImageStream` function, including pulling images from external image registries that
the `ImageStream` might reference.

The `Task` and `TaskRun` samples here illustrate both how to:

- Have a `Step` in a `Task` use an `ImageStream` reference for its image
- Have a `Step` push a built image to the OpenShift internal image registry as part of hosting the built image in an `ImageStream`,
including doing so with the correct certificate so that the push can be performed with TLS verification turned on.

## Preliminary set up

In addition to the actual create of the `Task` and `TaskRun`, the following steps are needed:

- As an administrator to the cluster, create a new `ClusterRole` that allows your `Task` to fetch the internal image registry
certificate for communicating over TLS.

```bash
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/openshift-image-stream/role-image-registry-ca.yaml
```

- You can then create a `ClusterRoleBinnding` to the service account you will use for your `TaskRun`.  The example here
uses the `builder` service account.  That service account will exist in every OpenShift namespace and will have the 
necessary authorization secrets to push images to the internal image registry.  If you are using the `OpenShift Pipelines`
OLM Operator from the OpenShift Operator Hub, you can also use the `pipeline` service account, as it also has the necessary
authorization secrets.  You can create the `ClusterRoleBinding` with the following command from the `oc` binary (the 
OpenShift extension to `kubectl`):

```bash
oc adm policy add-cluster-role-to-user openshift-image-registry-tekton -z builder
```

- This `ClusterRole` will enable a POC tool we have included in this sample.  The [OpenShift Build Utilities](https://github.com/gabemontero/obu)
is some helper code around leveraging some of the features associated with another OpenShift extension to Kubernetes,
[OpenShift Builds](https://docs.okd.io/latest/builds/understanding-image-builds.html), from within Tekton.  Please do
provide feedback via GitHub issues on the repo, as we are looking to see if such pieces of function will be useful
to Tekton users, versus having to duplicate the function in some sort of manual or roll-you-own fashion.  If it does
prove useful, we'll most likely include it in some official capacity with `OpenShift Pipelines`.  In this particular sample, we 
are retrieving the certificate for the internal image registry with the utility. 

- You next need to create a couple of `ImageStreams` that will be used by the `Task`.  The first is the `ImageStream` 
the built image will be pushed to.  Create it with:

```bash
oc create is test-imagestream-push
```

- The second `ImageStream` is for hosting the `buildah` image that we'll use for building and pushing images.  There 
are examples of using `buildah` in this repo without `ImageStreams` [here](https://github.com/tektoncd/catalog/tree/master/buildah).
For this `ImageStream`, we recommend creating it with the following `oc` command:

```bash
oc import-image buildah --confirm --from=quay.io/buildah/stable:v1.11.0
```

- Finally, we are going to enable our `ImageStream` named `buildah` so that OpenShift will dynamically modify the image
used for any Kubernetes object with a special annotation (which will be set on the `Task` per the instructions below),
specifically seeing if the existing image reference is an `ImageStream` reference and interrogating the `ImageStream` to
get the actual image reference.  The feature is documented [here](https://docs.okd.io/3.11/dev_guide/managing_images.html#using-is-with-k8s).
Use the following command to enable the `ImageStream` for this feature:

```bash
oc set image-lookup buildah
```

## Install the Tasks

Install the `imagestream-with-buildah` `Task` with :
```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/openshift-image-stream/task-imagestream-buildah.yaml
```

**NOTE**:  if you notice the annotation `alpha.image.policy.openshift.io/resolve-names: '*'` in your `Task`, that is how
one opts into the OpenShift support to translate any image references in the object that refer to `ImageStreams`. 

**NOTE**:  currently the `oc set image-lookup task.tekton.dev/imagestream-with-buildah` does not work with CRD based objects.

Finally, you can initiate the `TaskRun` with:

```bash
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/openshift-image-stream/taskrun-imagestream-buildah.yaml
```

Currently the `TaskRun` yaml applied above sets the git URL input and completes the set up of the `imageregistry`
Tekton `Workspace` that we leverage in this example.

## Inputs

### Parameters

* **INTERMEDIATE_OUTPUT_IMAGE:** The output image from the build that is pushed to the OpenShift internal image registry's location for the ImageStream. (_default_: `nodejs-tekton-example/output:latest`)

* **IMAGESTREAM_NAME:** The name of the ImageStream in the TaskRun's namespace that this example works with. (_default_: `test-imagestream-push`)

* **DOCKERFILE:**  Path to the Dockerfile to build. (_default_: `./Dockerfile`)

* **CONTEXT:**  Path to the directory to use as context. (_default_: `.`)

* **TLSVERIFY:**  Verify the TLS on the registry endpoint. (_default_: `true`)


## Outputs

As there is currently no way to dynamically set the image value of a Tekton `PipelineResource` image type, this
sample refrains from using the image output type.

You can run `oc get is test-imagestream-push -o yaml` to see that our resulting image was added to the `ImageStream`
and pushed to the internal image registry.

You'll see something like:

```yaml
$ oc get is test-imagestream-push -o yaml
apiVersion: image.openshift.io/v1
kind: ImageStream
metadata:
  creationTimestamp: "2020-03-11T20:23:08Z"
  generation: 1
  name: test-imagestream-push
  namespace: ggmtest2
  resourceVersion: "160225"
  selfLink: /apis/image.openshift.io/v1/namespaces/ggmtest2/imagestreams/test-imagestream-push
  uid: d6c89924-c6a1-4f2f-9fcb-a0dd6614fc36
spec:
  lookupPolicy:
    local: false
status:
  dockerImageRepository: image-registry.openshift-image-registry.svc:5000/ggmtest2/test-imagestream-push
  tags:
  - items:
    - created: "2020-03-11T20:26:27Z"
      dockerImageReference: image-registry.openshift-image-registry.svc:5000/ggmtest2/test-imagestream-push@sha256:04ec9a18c076377d9b5d5b08848eb0f00d752cb3be73742d7159ed09fc5e8118
      generation: 1
      image: sha256:04ec9a18c076377d9b5d5b08848eb0f00d752cb3be73742d7159ed09fc5e8118
    tag: latest
```

That imagestream can be used in subsequent `Deployments` or similar `Pod` wrappers to test the image you built.