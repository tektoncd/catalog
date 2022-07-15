# Post a message to a Microsoft Teams Channel

These tasks post a simple message to a Microsoft Teams Channel.

# send-to-microsoft-teams

This task uses the Incoming Webhook functionality of Microsoft Teams.
Create this webhook as described [here](https://docs.microsoft.com/en-us/microsoftteams/platform/webhooks-and-connectors/how-to/add-incoming-webhook).

## Install the Task and create a secret

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/send-to-microsoft-teams/0.1/raw
```

Create a secret that has the webhook URL in it.

Example of the secret:
```
kind: Secret
apiVersion: v1
metadata:
  name: microsoft-teams-webhook-url-secret
stringData:
  url: {incoming webhook url over here}
```

## Parameters

* **webhook-url-secret**: The name of the Secret for the incoming webhook URL.

* **webhook-url-secret-key**: The key within the secret for the URL.

* **message**: Plain text message to be posted in the chat.

## Platforms

The Task can be run on `linux/amd64`, `linux/s390x` and `linux/ppc64le` platforms.

## Usage

This TaskRun runs the Task to post a message to the the teams channel.

```
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: run-send-to-microsoft-teams
spec:
  params:
  - name: webhook-url-secret
    value: microsoft-teams-webhook-url-secret
  - name: webhook-url-secret-key
    value: url
  - name: message
    value: "Hello from Tekton!"
  taskRef:
    name: send-to-microsoft-teams

```
