# Kythe

These `Tasks` are [Kythe](https://kythe.io) tasks to generating annotations for
source code.

## `kythe-go`

The `kythe-go` `Task` runs the
[Kythe Go extractor](https://github.com/kythe/kythe/tree/master/kythe/go/extractors/cmd/gotool)
for the given package, placing the resulting kzips in the `output` workspace.

> Minimum Pipelines version required to run this Task is `v0.27.0` as it variable substitution
> of `mountPath` was introduced in this release.

### Workspaces

- **output**: A workspace for this Task to place kzip outputs into.

### Parameters

- **package**: Go package pattern to analyze.

## Platforms

The Task can be run on `linux/amd64` platform.
