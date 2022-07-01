# Kraken-scenario

The kraken-scenario task execute a chaos test against a cluster and return a OK if test is positive.

## Install the Kraken-scenario task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/kraken-scenario/0.1/kraken-scenario.yaml
```

## Parameters

| Key                            | Default                      | Description                                                                                                     |
| ------------------------------ | ---------------------------- | --------------------------------------------------------------------------------------------------------------- |
| cloudProviderCredentialsSecret | `kraken-cloudprovider-creds` | Name of the secret key holding the aws-credentials (mandatory but used only for aws infrastructure chaos test). |

## Workspaces

| Key               | Mount                 | Description                                                                                                       |
| ----------------- | --------------------- | ----------------------------------------------------------------------------------------------------------------- |
| kraken-kubeconfig | `/root/.kube`         | The kubeconfig configuration file of the targeted cluster. Must be in a `config` key if from configMap or Secret. |
| kraken-config     | `/root/kraken/config` | The kraken configuration file defining the chaos scenario to run                                                  |
| kraken-common     | `/root/kraken/common` | The kraken common configuration files related to the chaos configuration                                          |

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

This task require to run with a privileged context. 
You can allow the `pipeline` service account of you current project with the following command :

```bash
oc adm policy add-scc-to-user privileged -z pipeline
```

This task should be run with a pre-existing context composed of various `secret` and `configMap` resources. 
You must check the [samples files](https://github.com/tektoncd/catalog/tree/main/task/kraken-scenario/0.1/samples) 
before running you task.

When you have created your 
`kraken-cloudprovider-creds` Secret ([example](https://github.com/tektoncd/catalog/tree/main/task/kraken-scenario/0.1/samples/kraken-cloudprovider-creds.yaml)),
`kraken-common-example` configMap ([example](https://github.com/tektoncd/catalog/tree/main/task/kraken-scenario/0.1/samples/kraken-common-example.yaml)),
`kraken-config-example` configMap ([example](https://github.com/tektoncd/catalog/tree/main/task/kraken-scenario/0.1/samples/kraken-config-example.yaml)) and
`kraken-kubeconfig` configMap ([example](https://github.com/tektoncd/catalog/tree/main/task/kraken-scenario/0.1/samples/kraken-kubeconfig.yaml)) you can
run your chaos scenario (defined in your `kraken-config-example` configuration) with a simple taskrun.

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: kraken-scenario-example-run
  annotations:
    tekton.dev/displayName: Run a task with a single kraken chaos test of 2 x up to 3 pod pickup by hazard.
spec:
  taskRef:
    name: kraken-scenario
  params:
    - name: cloudProviderCredentialsSecret
      value: "kraken-cloudprovider-creds"
  workspaces:
  - name: kraken-kubeconfig
    configMap:
      name: kraken-kubeconfig
  - name: kraken-config
    configMap:
      name: kraken-config-example
  - name: kraken-common
    configMap:
      name: kraken-common-example
```