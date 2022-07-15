# Post a message to slack

These tasks post a simple message to a slack channel.  There are multiple ways to send
a message to slack. Each task here uses different method.


# send-to-channel-slack

This task uses chat.postMessage slack REST api to send the message.
Follow instructions [here](https://api.slack.com/messaging/sending) to obtain the OAuth access token for the bot app with `chat:write` scope.
The app must join the channel before the message posted by this task run. (invite the app in the channel)

## Install the Task and create a secret

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/send-to-channel-slack/0.1/raw
```

Create a secret that has the OAuth token of the bot app.

Example token-secret.yaml
```
kind: Secret
apiVersion: v1
metadata:
  name: token-secret
stringData:
  token: {OAuth token for the bot app}
```

Example kubectl command
```
kubectl apply -f token-secret.yaml
```

## Inputs

### Parameters

* **token-secret**: The name of the secret that has the OAuth token.  The key for the OAuth-token is token

* **channel**: [channel id](https://api.slack.com/messaging/retrieving#finding_conversation) or channel name where the message is posted

* **message**: Plain text message to be posted in the slack channel


## Platforms

The Task can be run on `linux/amd64`, `linux/s390x` and `linux/ppc64le` platforms.

## Usage

This TaskRun runs the Task to post a message to the channel.

```
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: run-send-to-channel-slack
spec:
  params:
  - name: token-secret
    value: token-secret
  - name: channel
    value: {CHANNEL ID}
  - name: message
    value: "Hello from Tekton!"
  taskRef:
    name: send-to-channel-slack
```
