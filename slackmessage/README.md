# Post a message to slack

These tasks post a simple message to a slack channel.  There are multiple ways to send
a message to slack.  Each task here uses different method.

# send-to-webhook-slack

This task uses Incomming Webhooks of the slack to send the message.
Follow instructions [here](https://api.slack.com/messaging/webhooks) to generate a webhook URL.

## Install the Task and create a secret

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/slackmessage/send-to-webhook-slack.yaml
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

## Inputs

### Parameters

* **webhook-secret**: The name of the secret that has the webhook URL.  The key for the URL is url

* **message**: Plain text message to be posted in the slack channel

## Usage

This TaskRun runs the Task to post a message to the channel that the webhook URL is associated with.

```
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  name: run-send-to-webhook-slack
spec:
  inputs:
    params:
      - name: webhook-secret
        value: webhook-secret
      - name: message
        value: "Hello from Tekton!"
  taskRef:
    name: send-to-webhook-slack

```

# send-to-channel-slack

This task uses chat.postMessage slack REST api to send the message.
Follow instructions [here](https://api.slack.com/messaging/sending) to obtain the OAuth access token for the bot app with `chat:write` scope.
The app must join the channel before the message posted by this task run. (invite the app in the channel)

## Install the Task and create a secret

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/slackmessage/send-to-channel-slack.yaml
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

## Usage

This TaskRun runs the Task to post a message to the channel.

```
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  name: run-send-to-channel-slack
spec:
  inputs:
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

