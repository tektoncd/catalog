# Set Traffic for Knative Service

Let's perform traffic splitting on the Knative Service using Pipeline.
If you followed the earlier two Pipeline examples, you already have a couple of Revisions available, that we'll reference in PipelineRun to
configure the Service to route 50-50% traffic to each Revision.

## Pipeline:

- The following Pipline is focused only on performing traffic operations
  on Service. It does not define/require any Pipeline resources.
- Save the following YAML in a file say e.g.: `kn_service_traffic_pipeline.yaml` and create using
 `kubectl create -f kn_service_traffic_pipeline.yaml`.

```yaml
apiVersion: tekton.dev/v1alpha1
kind: Pipeline
metadata:
  name: kn-service-traffic-splitting
spec:
  params:
  - name: ARGS
    type: array
    description: Arguments to pass to kn CLI
    default:
      - "help"
  tasks:
  - name: kn-service-traffic-splitting
    taskRef:
      name: kn
    params:
    - name: kn-image
      value: "gcr.io/knative-nightly/knative.dev/client/cmd/kn"
    - name: ARGS
      value:
        - "$(params.ARGS)"
```

 - You can also create this Pipeline using the YAML file present in this repo using
```
kubectl create -f https://raw.githubusercontent.com/tektoncd/catalog/master/kn/knative-dockerfile-deploy/service_traffic/kn_service_traffic_pipeline.yaml
```

## PipelineRun:

- Create the PipelineRun to trigger the Pipeline and provide the kn CLI arguments to perform the traffic splitting.
- Note that, we're referencing Revisions `hello-v1` and `hello-v2` here, which we've created in earlier Pipeline examples.
- Save the following YAML in a file e.g: `pipeline_run.yaml` and create using
 `kubectl create -f pipeline_run.yaml`.

```yaml
apiVersion: tekton.dev/v1alpha1
kind: PipelineRun
metadata:
  generateName: kn-service-traffic-splitting-
spec:
  serviceAccountName: kn-deployer-account
  pipelineRef:
    name: kn-service-traffic-splitting
  params:
    - name: ARGS
      value:
        - "service"
        - "update"
        - "hello"
        - "--tag=hello-v1=v1"
        - "--tag=hello-v2=v2"
        - "--traffic=v1=50"
        - "--traffic=v2=50"
```
- You can also create this PipelineRun using the YAML file present in this repo using
```
kubectl create -f https://raw.githubusercontent.com/tektoncd/catalog/master/kn/knative-dockerfile-deploy/service_traffic/pipeline_run.yaml
```

- Let's monitor the logs of the Pipeline run using `tkn`
```bash
tkn pr list
tkn pr logs <pipelinerun-name> logs -f
```

- After the successful run of the Pipeline, we should have the Knative Service updated with mentioned traffic settings
```bash
kubectl get ksvc hello
kubectl describe ksvc hello
```
