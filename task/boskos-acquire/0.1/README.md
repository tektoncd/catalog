# Boskos Acquire

The `boskos-acquire` Task can be used to acquire cloud projects from a pool with
[Boskos](https://github.com/kubernetes-sigs/boskos#boskos), by invoking `boskosctl`.

To release projects obtained with `boskos-acquire` can be released with
[`boskos-release`](../../boskos-release).

It is implemented using [`boskosctl`](https://github.com/kubernetes-sigs/boskos/tree/master/cmd/boskosctl).

_The Task assumes already have Boskos up and running. To set it up yourself, you
can look at [this example deployment](https://github.com/kubernetes-sigs/boskos/tree/master/deployments/overlays/example).

## ServiceAccount

After acquiring a project, the Task will start a running `pod` in your cluster to send
heartbeat requests to Boskos (Boskos will automatically clean up abandoned clusters).
This means the Task must be run with a serviceAccount that has the ability to interact
with `pods` (see [service-account.yaml](samples/service-account.yaml) for an example).

## Parameters

* **server-url**: The URL of the running boskos server. (_default_: http://boskos.test-pods.svc.cluster.local)
* **type**: The type of resource to request. Resource types are specified in the resource
            ConfigMap provided to the Boskos server. (_default_: gke-project)
* **owner-name**: A string that identifies the owner of the leased resource to request. (_required_)

## Results

* **leased-resource**: The name of the leased resource

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

See [samples/pipelinerun.yaml](samples/pipelinerun.yaml) for an example of a Pipeline that obtains
a resource using Boskos, then waits (this is when you would do whatever you need to do with the resource),
and finally releases it with [`boskos-release`](../../boskos-release).

Boskos doesn't do anything to provide you with the credentials you need to interact with the resource you
have leased. Setting up and managing these credentials is outside the scope of Boskos's responsibilities.
