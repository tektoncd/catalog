# Kythe

These `Tasks` are [Kythe](https://kythe.io) tasks to generating annotations for
source code.

## `kythe-go`

The `kythe-go` `Task` runs the
[Kythe Go extractor](https://github.com/kythe/kythe/tree/master/kythe/go/extractors/cmd/gotool)
for the given package, placing the resulting kzips in the `output` workspace.

### Workspaces

- **output**: A workspace for this Task to place kzip outputs into.

### Parameters

- **package**: Go package pattern to analyze.
