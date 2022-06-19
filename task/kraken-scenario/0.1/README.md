# STARTX

## Kraken-scenario

The kraken-scenario task execute a chaos test against a cluster and return a OK if test is positive.

### Install the Kraken-scenario task

```
kubectl apply -f https://raw.githubusercontent.com/startxfr/tekton-catalog/main/task/kraken-scenario/0.1/kraken-scenario.yaml
```

### Parameters

| Key                 | Default            | Description                                                                                                     |
| ------------------- | ------------------ | --------------------------------------------------------------------------------------------------------------- |
| awsCredentialSecret | `kraken-aws-creds` | Name of the secret key holding the aws-credentials (mandatory but used only for aws infrastructure chaos test). |
| serviceAccount      | `kraken`           | Name of the serviceAccount running the kraken task.                                                             |

### Workspaces

| Key               | Mount                 | Description                                                                                                       |
| ----------------- | --------------------- | ----------------------------------------------------------------------------------------------------------------- |
| kraken-kubeconfig | `/root/.kube`         | The kubeconfig configuration file of the targeted cluster. Must be in a `config` key if from configMap or Secret. |
| kraken-config     | `/root/kraken/config` | The kraken configuration file defining the chaos scenario to run                                                  |
| kraken-common     | `/root/kraken/common` | The kraken common configuration files related to the chaos configuration                                          |

## Platforms

The Task can be run on `linux/amd64` platform.

### Usage

This task should be run with a pre-existing context composed of various `secret` and `configMap` resources. 
You better check the [samples files](https://github.com/startxfr/tekton-catalog/tree/main/task/kraken-scenario/0.1/samples) 
instead of using this example _as if_.

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: kraken-scenario-test
spec:
  taskRef:
    name: kraken-scenario
  params:
    - name: awsCredentialSecret
      value: "kraken-aws-creds"
    - name: serviceAccount
      value: "kraken"
  workspaces:
  - name: kraken-kubeconfig
    configMap:
      name: kraken-kubeconfig
  - name: kraken-config
    configMap:
      name: kraken-config-test
  - name: kraken-common
    configMap:
      name: kraken-common-test
```