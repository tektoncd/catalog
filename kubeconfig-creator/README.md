# Kubeconfig Creator Task

This `Task` do a similar job to the [Cluster](https://github.com/tektoncd/pipeline/blob/master/docs/resources.md#cluster-resource) 
`PipelineResource` and
are intended as its replacement. This is part of our plan to [offer replacement
`tasks` for Pipeline Resources](https://github.com/tektoncd/catalog/issues/95)
as well as
[document those replacements](https://github.com/tektoncd/pipeline/issues/1369).

This task creates a [kubeconfig](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/)
file that can be used to configure access to the different clusters.
A common use case for this task is to deploy your `application/function` on different clusters.

The task will use the [kubeconfigwriter](https://github.com/tektoncd/pipeline/blob/master/cmd/kubeconfigwriter/main.go) 
image and the provided parameters to create a `kubeconfig` file that can be used by other tasks
in the pipeline to access the target cluster. The kubeconfig will be placed at 
`/workspace/<workspace-name>/kubeconfig`.

This task provides users variety of ways to authenticate:
- Authenticate using tokens.
- Authenticate using client key and client certificates.

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/kubeconfig-creator/kubeconfig-creator.yaml
```

## Workspace

* **output**: A workspace that stores the generated kubeconfig file, such that it can be used in the other tasks to access the cluster.


## Parameters

* **Name**: Name of the `cluster`.
* **URL**: Address of the target cluster (_e.g.:_ 
  `https://hostname:port`)
* **Username**: Username for basic authentication to the cluster
(_default:_ `""`)
* **Password**: Password for basic authentication to the cluster
(_default:_ `""`)
* **Cadata**: Contains PEM-encoded certificate authority certificates
(_default:_ `""`)
* **ClientKeyData**: Contains PEM-encoded data from a client key file for TLS
(_default:_ `""`)
* **ClientCertificateData**: Contains PEM-encoded data from a client cert file for TLS 
(_default:_ `""`)
* **Namespace**: Default namespace to use on unspecified requests
(_default:_ `""`)
* **Token**: Bearer token for authentication to the cluster
(_default:_ `""`)
* **Insecure**:  If true, skips the validity check for the server's certificate. 
This will make your HTTPS connections insecure
(_default:_ `false`)


## Usage

This [example](../kubeconfig-creator/example) task uses a 
`shared workspace` with [`PVC`](https://kubernetes.io/docs/concepts/storage/persistent-volumes) 
to store the `kubeconfig` in the `output` directory. 
Kubeconfig file is stored at `/workspace/<workspace-name>/kubeconfig`.

Task can be used with the other task in the pipeline to authenticate the cluster.
In this example, pipeline has a task `kubeconfig-creator` that generates a 
`kubeconfig file` for the cluster and the `test-task` uses that kubeconfig file and verifiy whether the
application has an access to the cluster or not by using some `kubectl/oc` commands.

Required `params` can be passed in the pipeline as follows:

```
params:
  - name: name
    value: cluster-bot
  - name: username
    value: admin
  - name: url
    value: https://api.ci-ln-13f81c2-d5d6b.origin-ci-int-aws.dev.rhcloud.com:6443
  - name: cadata
    value: LS0tLS1C....
  - name: clientCertificateData
    value: LS0tLS1C....
  - name: clientKeyData
    value: LS0tLS1C....
```
[This](../kubeconfig-creator/example/pipeline.yaml) can be referred for the pipeline example.


`Test-task` uses shared-workspace to fetch the kubeconfig file from the
`input` named workspace and uses `oc` commands to check whether
 the `cluster` is configured or not.

```
steps:
  - name: get
    image: quay.io/openshift/origin-cli:latest
    script: |
      export KUBECONFIG="$(workspaces.input.path)/$(inputs.params.filename)"
      #
      # check that the cluster is configured
      oc get pods
```

Workspace with `PVC` is used, as shown below.
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: kubeconfig-pvc
spec:
  resources:
    requests:
      storage: 5Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
   ```

 Finally, PipelineRun is used to execute the tasks in the pipeline and get the results.
 Reference for sample PipelineRun can be found [here](../kubeconfig-creator/example/pipelinerun.yaml).
 
***NOTE***

- Since only one `authentication` technique is allowed per user, either a `token` or a `password` should be provided, if both are provided, the password will be ignored.

- `clientKeyData` and `clientCertificateData` are only required if `token` or `password` is not provided for authentication to cluster.