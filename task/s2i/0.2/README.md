# Source-to-Image

[Source-to-Image (S2I)](https://github.com/openshift/source-to-image)
is a toolkit and workflow for building reproducible container images
from source code. S2I produces images by injecting source code into a
base S2I container image and letting the container prepare that source
code for execution. The base S2I container images contains the
language runtime and build tools needed for building and running the
source code.

## Install the Task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/s2i/0.2/raw
```

## Parameters

- **IMAGE_NAME**: Reference of the image S2I will produce.
- **BUILDER_IMAGE**: The location of the s2i builder image.
- **PATH_CONTEXT**: Source path from where s2i command need to be run
  (_default: ._).
- **TLSVERIFY**: Verify the TLS on the registry endpoint (for push/pull to a
  non-TLS registry) (_default:_ `true`)

## Workspaces

- **source**: A [Workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md) containing the source to build.
- **sslcertdir**: An [_optional_ Workspace](https://github.com/tektoncd/pipeline/blob/v0.17.0/docs/workspaces.md#optional-workspaces) containing your custom SSL certificates to connect to the registry. Buildah will look for files ending with \*.crt, \*.cert, \*.key into this workspace. See [this sample](./samples/openshift-internal-registry.yaml) for a complete example on how to use it with OpenShift internal registry.

## Results

- **IMAGE_DIGEST**: Digest of the image just built.

## ServiceAccount

S2I builds an image and pushes it to the destination registry which is
defined as a parameter. In order to properly authenticate to the
remote container registry, it needs to have the proper
credentials. The credentials can be provided through a service
account. See
[Authentication](https://github.com/tektoncd/pipeline/blob/main/docs/auth.md#basic-authentication-docker)
for further details.

If you are running on OpenShift, you also need to allow the service
account to run privileged containers because OpenShift does not allow
containers run as privileged containers by default unless explicitly
configured, due to security considerations.

Run the following in order to create a service account named
`pipeline` on OpenShift and allow it to run privileged containers:

```bash
oc create serviceaccount pipeline
oc adm policy add-scc-to-user privileged -z pipeline
oc adm policy add-role-to-user edit -z pipeline
```

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

This PipelineRun runs the Task to fetch a Git repo, and build and push a
container image using s2i and a nodejs builder image.

```yaml
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: s2i-test-pipeline-run
spec:
  pipelineSpec:
    workspaces:
      - name: shared-workspace
      - name: sslcertdir
        optional: true
    tasks:
      - name: fetch-repository
        taskRef:
          name: git-clone
        workspaces:
          - name: output
            workspace: shared-workspace
        params:
          - name: url
            value: https://github.com/sclorg/nodejs-ex
          - name: subdirectory
            value: ""
          - name: deleteExisting
            value: "true"
      - name: s2i
        taskRef:
          name: s2i
        runAfter:
          - fetch-repository
        workspaces:
          - name: source
            workspace: shared-workspace
        params:
          - name: BUILDER_IMAGE
            value: quay.io/centos7/nodejs-12-centos7
          - name: TLSVERIFY
            value: "false"
          - name: LOGLEVEL
            value: "10"
          - name: IMAGE_NAME
            value: image-registry.openshift-image-registry.svc:5000/$(context.pipelineRun.namespace)/$(context.pipelineRun.name)
  workspaces:
    - name: shared-workspace
      volumeClaimTemplate:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 100Mi
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
  - [`centos/python-38-centos7`](https://hub.docker.com/r/centos/python-38-centos7)
- [ruby](https://github.com/sclorg/s2i-ruby-container)
  - [`centos/ruby-23-centos7`](https://hub.docker.com/r/centos/ruby-23-centos7)
  - [`centos/ruby-24-centos7`](https://hub.docker.com/r/centos/ruby-24-centos7)
  - [`centos/ruby-25-centos7`](https://hub.docker.com/r/centos/ruby-25-centos7)

#### Note: 
- All those images above are also available with RHEL as base
instead, just replace `centos7` by `rhel7` or `rhel8` when using from DockerHub
- The following images are also available at quay.io/centos7
