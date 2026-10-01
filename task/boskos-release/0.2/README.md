# Boskos Release

The `boskos-release` Task can be used to release cloud projects
which were obtained from a pool with [Boskos](https://github.com/kubernetes-sigs/boskos#boskos)
via [`boskos-acquire`](../../boskos-acquire).

It will mark the resource as `dirty` so that Boskos will clear any obtained resources.

It is implemented using [`boskosctl`](https://github.com/kubernetes-sigs/boskos/tree/master/cmd/boskosctl).

_The Task assumes already have Boskos up and running. To set it up yourself, your
best bet would be to find an example of it already configured, for example
[the boskos configuration used for Tekton itself](https://github.com/tektoncd/plumbing/tree/main/boskos)._

## ServiceAccount

[`boskos-acquire`](../boskos-acquire) will start a `pod` in your cluster to maintain the lease
via a heartbeat. `boskos-release` will delete that pod, and so the Task must be run with a
serviceAccount that has the ability to delete `pods` (see [service-account.yaml](samples/service-account.yaml) for an example).

## Parameters

* **server-url**: The URL of the running boskos server. (_default_: http://boskos.test-pods.svc.cluster.local)
* **leased-resource**: The name of the leased resource. (_required_)
* **owner-name**: A string that identifies the owner of the leased resource to request. (_required_)

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

See [samples/pipelinerun.yaml](samples/pipelinerun.yaml) for an example of a Pipeline that obtains
a resource using [`boskos-acquire`](../../boskos-acquire), then waits (this is when you would do whatever
you need to do with the resource), and finally releases it with `boskos-release`.
