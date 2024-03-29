# Deploy new revision to a Knative Service

Let's create a Pipeline which deploys a new Revision to the deployed Knative Service.
A new Revision is created if you update the Configuration of the Service.

## Pipeline:
- The following Pipeline is generic `kn` Pipeline, which can update (or even create a new) Knative Service based to the parameters you provide.
- Save the following YAML in a file say e.g.: `kn_service_update_pipeline.yaml` and create using `kubectl create -f kn_service_update_pipeline.yaml`.

```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: kn-service-update
spec:
  params:
  - name: ARGS
    type: array
    description: Arguments to pass to kn CLI
    default:
      - "help"
  tasks:
  - name: kn-service-update
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
https://raw.githubusercontent.com/tektoncd/catalog/main/task/kn/0.2/knative-dockerfile-deploy/service_update/kn_service_update_pipeline.yaml
```

## PipelineRun

- Create the PipelineRun to trigger the Pipeline and input the kn CLI parameters to 
deploy a new Revision to `hello` Service. Note that in the below example, we're referencing a 
different image, other than the one we created earlier using buildah.

- Save the following YAML in a file e.g.: `pipeline_run.yaml` and create using `kubectl create -f pipeline_run.yaml`

```yaml
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  generateName: kn-service-update-
spec:
  serviceAccountName: kn-deployer-account
  pipelineRef:
    name: kn-service-update
  params:
    - name: ARGS
      value:
        - "service"
        - "update"
        - "hello"
        - "--revision-name=hello-v2"
        - "--image=gcr.io/knative-samples/helloworld-go"
        - "--env=TARGET=v2"
        - "--service-account=kn-deployer-account"
```

- You can also create this PipelineRun using the YAML file present in this repo using
```
https://raw.githubusercontent.com/tektoncd/catalog/main/task/kn/0.2/knative-dockerfile-deploy/service_update/pipeline_run.yaml
```

Let's monitor the logs of the Pipeline run using `tkn`
```bash
tkn pr list
tkn pr logs <pipelinerun-name> logs -f
```

After the successful run of the Pipeline, we should have the Service updated, let's check
```bash
kubectl get ksvc hello
```

## What's Next:
- We've updated the Knative Service and now we've two Revisions present, we can use this state to also perform
  some traffic splitting operation on the Service, check out the [next Pipeline example](../service_traffic/README.md).
