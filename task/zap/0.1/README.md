# Zap proxy

[Zap proxy](https://github.com/zaproxy/zaproxy) baseline is a command line tool for security scanning endpoints.

## Install the Task

```shell
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/task/zap/0.1/zap-baseline.yaml
```

## Parameters

- **testURL**: The URL to be scanned

## Workspace

- **zap-folder**: A RW folder where all zap output files is stored.

## Usage

See [here](../0.1/samples/run.yaml) for example of `TaskRun`.
