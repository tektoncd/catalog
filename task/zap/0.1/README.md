# Zap proxy

[Zap proxy](https://github.com/zaproxy/zaproxy) baseline is a command line tool for security scanning endpoints.

## Install the Task

```shell
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/task/zap/0.1/zap-baseline.yaml
```

## Parameters

- **testURL**: The URL to be scanned.
- **configFile**: Path to zap-scan-config, is stored under /zap/wrk/, ca you only set the file name.
- **cmName**: Name of cm containing scan.conf
- **mins**: Number of minutes to let the scanner run

## Workspace

- **zap-folder**: A RW folder where all zap output files is stored.

## Usage

See [here](../0.1/samples/run.yaml) for example of `TaskRun`.

The [configmap](../0.1/samples/zap-scan-config.yaml) is generated from the
```podman run -it -v $(pwd):/zap/wrk/:Z quay.io/nissessenap/zap-proxy:0.0.1 zap-baseline.py -t https://www.zaproxy.org/ -g gen.conf -r testreport.html``` command.

Read more about the how to configure the scan config [here:](https://www.zaproxy.org/docs/docker/baseline-scan/)

**NOTE** that the tabs in the scan.conf file is important.
