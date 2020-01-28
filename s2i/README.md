# Source-to-Image

[Source-to-Image (S2I)](https://github.com/openshift/source-to-image)
is a toolkit and workflow for building reproducible container images
from source code. S2I produces images by injecting source code into a
base S2I container image and letting the container prepare that source
code for execution. The base S2I container images contains the
language runtime and build tools needed for building and running the
source code.

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/s2i/s2i.yaml
```

## Inputs

### Parameters

* **BUILDER_IMAGE**: The location of the s2i builder image.
* **PATH_CONTEXT**: Source path from where s2i command need to be run
  (_default: ._).
* **TLSVERIFY**: Verify the TLS on the registry endpoint (for push/pull to a
  non-TLS registry) (_default:_ `true`)


### Resources

* **source**: A `git`-type `PipelineResource` specifying the location of the
  source to build.

## Outputs

### Resources

* **image**: An `image`-type `PipelineResource` specify the image that should
  be built.

## ServiceAccount

S2I builds an image and pushes it to the destination registry which is
defined as a parameter. In order to properly authenticate to the
remote container registry, it needs to have the proper
credentials. The credentials can be provided through a service
account. See
[Authentication](https://github.com/tektoncd/pipeline/blob/master/docs/auth.md#basic-authentication-docker)
for further details.

If you are running on OpenShift, you also need to allow the service
account to run privileged containers because OpenShift does not allow
containers run as privileged containers by default unless explicitly
configured, due to security considerations.

Run the following in order to create a service account named
`pipeline` on OpenShift and allow it to run privileged containers:

```
oc create serviceaccount pipeline
oc adm policy add-scc-to-user privileged -z pipeline
oc adm policy add-role-to-user edit -z pipeline
```

## Usage

This TaskRun runs the Task to fetch a Git repo, and build and push a
container image using s2i and a nodejs builder image.

```
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  name: s2i-nodejs-taskrun
spec:
  # Use service account with git and image repo credentials
  serviceAccountName: pipeline
  taskRef:
    name: s2i
  inputs:
    params:
	- name: BUILDER_IMAGE
	  value: docker.io/centos/nodejs-8-centos7
    resources:
    - name: source
      resourceSpec:
        type: git
        params:
        - name: url
          value: https://github.com/sclorg/nodejs-ex
  outputs:
    resources:
    - name: image
      resourceSpec:
        type: image
        params:
        - name: url
          value: gcr.io/my-repo/nodejs-s2i-ex

```

Here is a non-exhaustive list of well maintained s2i builder image
(from [`sclorg`](https://github.com/sclorg/)):

- [go](https://github.com/sclorg/golang-container)
  - [`centos/go-toolset-7-centos7`](https://github.com/sclorg/golang-container)
- [nodejs](https://github.com/sclorg/s2i-nodejs-container)
  - [`centos/nodejs-6-centos7`](https://hub.docker.com/r/centos/nodejs-6-centos7)
  - [`centos/nodejs-8-centos7`](https://hub.docker.com/r/centos/nodejs-8-centos7)
  - [`centos/nodejs-10-centos7`](https://hub.docker.com/r/centos/nodejs-10-centos7)
- [perl](https://github.com/sclorg/s2i-perl-container)
  - [`centos/perl-524-centos7`](https://hub.docker.com/r/centos/perl-524-centos7)
  - [`centos/perl-526-centos7`](https://hub.docker.com/r/centos/perl-526-centos7)
- [php](https://github.com/sclorg/s2i-php-container)
  - [`centos/php-70-centos7`](https://hub.docker.com/r/centos/php-70-centos7)
  - [`centos/php-71-centos7`](https://hub.docker.com/r/centos/php-71-centos7)
  - [`centos/php-72-centos7`](https://hub.docker.com/r/centos/php-72-centos7)
- [python](https://github.com/sclorg/s2i-python-container)
  - [`centos/python-27-centos7`](https://hub.docker.com/r/centos/python-27-centos7)
  - [`centos/python-35-centos7`](https://hub.docker.com/r/centos/python-35-centos7)
  - [`centos/python-36-centos7`](https://hub.docker.com/r/centos/python-36-centos7)
  - [`centos/python-37-centos7`](https://hub.docker.com/r/centos/python-37-centos7)
- [ruby](https://github.com/sclorg/s2i-ruby-container)
  - [`centos/ruby-23-centos7`](https://hub.docker.com/r/centos/ruby-23-centos7)
  - [`centos/ruby-24-centos7`](https://hub.docker.com/r/centos/ruby-24-centos7)
  - [`centos/ruby-25-centos7`](https://hub.docker.com/r/centos/ruby-25-centos7)

*Note: all those images above are also available with RHEL as base
instead, just replace `centos7` by `rhel7` or `rhel8`*
