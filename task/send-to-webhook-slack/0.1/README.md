# Post a message to slack

These tasks post a simple message to a slack channel.  There are multiple ways to send
a message to slack. Each task here uses different method.

# send-to-webhook-slack

This task uses Incoming Webhooks of slack to send the message.
Follow instructions [here](https://api.slack.com/messaging/webhooks) to generate a webhook URL.

## Install the Task and create a secret

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/send-to-webhook-slack/0.1/raw
```

Create a secret that has the generated webhook URL

Example webhook-secret.yaml
```
kind: Secret
apiVersion: v1
metadata:
  name: webhook-secret
stringData:
  url: {generated webhook URL}
```

Example kubectl command
```
kubectl apply -f webhook-secret.yaml
```

## Parameters

* **webhook-secret**: The name of the secret that has the webhook URL.  The key for the URL is url

* **message**: Plain text message to be posted in the slack channel

* **bot-name**: The name of the bot to use. Defaults to `Tekton Bot`.

* **icon-emoji**: The emoji to use for the bot. For example you could import a tekton emoji and use `:tekton:` over here.

## Platforms

The Task can be run on `linux/amd64`, `linux/s390x` and `linux/ppc64le` platforms.

## Usage

This TaskRun runs the Task to post a message to the channel that the webhook URL is associated with.

```
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: run-send-to-webhook-slack
spec:
  params:
  - name: webhook-secret
    value: webhook-secret
  - name: message
    value: "Hello from Tekton!"
  taskRef:
    name: send-to-webhook-slack

```
