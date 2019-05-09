# BuildKit

This Task builds source into a container image using [Moby BuildKit](https://github.com/moby/buildkit).

Rootless mode is used by default.

## Install the Task

### Step 0: Deploy BuildKit daemon

First, you need to deploy BuildKit daemon as follows:

```console
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/buildkit/0-buildkitd.yaml
```

You can adjust the number of replicas as you like.

The default image is set to `moby/buildkit:vX.Y.Z-rootless@sha256:...` (see YAML files for the actual revision), but you can also build the image manually as follows:

```console
git clone https://github.com/moby/buildkit.git
cd buildkit
DOCKER_BUILDKIT=1 docker build --target rootless -f hack/dockerfiles/test.buildkit.Dockerfile .
```

If you are using Debian (not Ubuntu) or Arch Linux kernel on each of kubelet nodes, `sudo sh -c "echo 1 > /proc/sys/kernel/unprivileged_userns_clone"` is required.
On RHEL/CentOS 7, `sudo sh -c "echo 28633 > /proc/sys/user/max_user_namespaces"` is required.

See the content of [`0-buildkitd.yaml`](./0-buildkitd.yaml) for further information about rootless mode.

You can also use "rootful" BuildKit image (`moby/buildkit:vX.Y.Z`) at your own risk.

### Step 1: Install the task

```console
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/buildkit/1-task.yaml
```

## Inputs

### Parameters

* **DOCKERFILE**: The path to the `Dockerfile` to execute (_default:_  `./Dockerfile`)
* **BUILDKIT_CLIENT_IMAGE**: BuildKit client image (_default:_`moby/buildkit:vX.Y.Z@sha256:...`)
* **BUILDKIT_DAEMON_ADDRESS**: BuildKit daemon address  (_default:_`tcp://buildkitd:1234`)

### Resources

* **source**: A `git`-type `PipelineResource` specifying the location of the
  source to build.

## Outputs

### Resources

* **image**: An `image`-type `PipelineResource` specifying the image that should
  be built.

