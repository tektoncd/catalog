# BuildKit

This Task builds source into a container image using [Moby BuildKit](https://github.com/moby/buildkit).

See also [`buildkit-daemonless`](../buildkit-daemonless) for the daemonless version of this task.

## Install

### Step 0: Create mTLS secrets

You need to determine the SAN of the BuildKit daemon `Service` and create mTLS certificates.
In this example, we use `buildkitd` as the SAN.

```console
$ ./create-certs.sh buildkitd
$ kubectl apply -f .certs/buildkit-daemon-certs.yaml
secret/buildkit-daemon-certs created
$ kubectl apply -f .certs/buildkit-client-certs.yaml
secret/buildkit-client-certs created
$ rm -rf .certs
```

### Step 1: Deploy BuildKit daemon

Two types of the daemon manifests are included:

* `deployment+service.rootless.yaml` (recommended):
  Run the daemon as a non-root user.
  Using Ubuntu nodes is recommended.
  [Needs `sysctl` configuration for Debian hosts and RHEL/CentOS 7 hosts. Does not work on Google COS.](https://github.com/moby/buildkit/blob/master/docs/rootless.md)
* `deployment+service.privileged.yaml`:
  Run the daemon as the root user with `securityContext.privileged=true`.
  Try this version if `deployment+service.rootless.yaml` does not work or too slow.

```console
$ kubectl apply -f deployment+service.rootless.yaml
deployment.apps/buildkitd created
service/buildkitd created
```

The number of replicas can be adjusted as you like:

```console
$ kubectl scale --replicas=10 deployment/buildkitd
```

See also [BuildKit documentation](https://github.com/moby/buildkit/tree/master/examples/kubernetes) for the further information about the manifests.

### Step 2: Install the task

```console
$ kubectl apply -f task.yaml
task.tekton.dev/buildkit created
```

## Inputs

### Parameters

* **DOCKERFILE**: The path to the `Dockerfile` to execute (_default:_  `./Dockerfile`)
* **BUILDKIT_CLIENT_IMAGE**: BuildKit client image (_default:_`moby/buildkit:vX.Y.Z@sha256:...`)
* **BUILDKIT_DAEMON_ADDRESS**: BuildKit daemon address  (_default:_`tcp://buildkitd:1234`)
* **BUILDKIT_CLIENT_CERTS**: The name of Secret that contains `ca.pem`, `cert.pem`, `key.pem`
  for mTLS connection to BuildKit daemon (_default:_`buildkit-client-certs`)

### Resources

* **source**: A `git`-type `PipelineResource` specifying the location of the source to build.

## Outputs

### Resources

* **image**: An `image`-type `PipelineResource` specifying the image that should be built.
  Currently, generating [`resourceResult`](https://github.com/tektoncd/pipeline/blob/master/docs/resources.md#image-resource) is not supported. ([`buildkit#993`](https://github.com/moby/buildkit/issues/993))

