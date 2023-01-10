# Gogit

GitHub and Gitlab have their own continuous integration (CI) systems, it's easy to see the status of pipelines. 
But when users decide to use an alternative CI tool instead of the build in, they will need extra steps to send the status back.
Similar to [gitea-set-status](../gitea-set-status/0.1/README.md), [gitlab-set-status](../gitlab-set-status/0.1/README.md), and [github-set-status](../github-set-status/0.1/README.md), this task could send build status to GitHub/Gitlab.

See more details from https://github.com/linuxsuren/gogit

## Install the task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/gogit/0.1/raw
```

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

This TaskRun runs the Task to send build status from
[`tektoncd/pipeline`](https://github.com/tektoncd/pipeline).

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: send-build-status
spec:
  taskRef:
    name: gogit
  params:
  - name: repo
    value: test
  - name: username
    value: linuxsuren
  - name: token
    value: my-token
  - name: pull_request_number
    value: my-pull-request-number
```
