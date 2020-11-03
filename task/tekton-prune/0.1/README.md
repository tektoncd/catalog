# tekton-prune

This task helps you prune tekton objects. This task is typically run in a scheduled jobs via [kubernetes cron](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) or other [traditional crons](https://en.wikipedia.org/wiki/Cron).

## Install the task

### Install the tekton-prune task

```bash
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/task/tekton-prune/0.1/tekton-prune.yaml
```

## Parameters

* **object**: The type of the kubernetes object to clean.  (i.e: `PipelineRun`, `TaskRuns`).
* **namespace**: The target namespace, if no target namespace is specified it would use the one where this taks is run (_Default_: `""`)
* **max_days**: Maximum number of days to keep. This accepts only an integer (_Default_: `""`)
* **max_number**: Maximum number of objects to keep. This accepts only an integer (_Default_: `""`)
* **labels**: The kubernetes labels to filter tekton objects. Multiple labels can separated by a comma. (_Default_: `""`)
* **no_execute**: Wether to execute the actual deletion or just print the object to delete. This accept a `yes` or `true` for positives or `no` or `false` for negative (_Default_: `""`)

## Usage

You need to make sure to have either `max_days` or `max_number` set or this task would fail.

You need to make sure that the `serviceAccount` that runs this task has the right to list tekton objects, see [the role](./tests/roles.yaml) of this test task for a `serviceAccount` with a `roleBinding` rights to list and delete `tekton` objects.

This kubernetes `CronJob` will cleanup the `PipelineRun` older than 5 days belonging to the Pipeline `pipeline`, this assume you have preinstalled the task where this cron is run and that you  have installed the `roleBindings` from `./test/roles.yaml` :

```yaml
---
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: cron-openshift-ci-build-images
spec:
  schedule: "0 0 * * 1"  # every Sunday night !
  concurrencyPolicy: "Forbid"
  startingDeadlineSeconds: 200
  suspend: false
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccount: tekton-object-role-binding
          containers:
          - name: use-tkn-for-cleanup
            image: gcr.io/tekton-releases/dogfooding/tkn
            command: ["/bin/sh"]
            args: ["-c", "tkn task start tekton-prune --serviceaccount tekton-object-role-binding --param  object=pipelinerun --param max_number=5 --param labels=tekton.dev/pipeline=pipeline --showlog"]
          restartPolicy: OnFailure
```
