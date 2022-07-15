# Post a message to Discord

These tasks post a message to a Discord channel.

# send-to-webhook-discord

This task uses Webhooks Integration to send a message in Discord channel.
Follow instructions [here](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks) to generate a webhook URL.

## Install the Task and create a secret

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/send-to-webhook-discord/0.1/raw
```

Create a secret that has the generated webhook URL

Example webhook-secret.yaml
```yaml
kind: Secret
apiVersion: v1
metadata:
  name: webhook-secret
stringData:
  url: {generated-webhook-URL}
```

Example kubectl command
```
kubectl apply -f webhook-secret.yaml
```

## Parameters

* **webhook-secret**: The name of the secret that has the webhook URL

* **message**: Plain text message to be posted in discord channel

* **bot-name**: The name of the bot to use. Defaults to `Tekton Bot`.

* **avatar-url**: Avatar image to use for the bot. For example you could use any valid image url.

## Platforms

The Task can be run on `linux/amd64`, `linux/s390x` and `linux/ppc64le` platforms.

## Usage

This TaskRun runs the Task to post a message to the channel that the webhook URL is associated with.

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: send-to-webhook-discord-run
spec:
  taskRef:
    name: send-to-webhook-discord
  params:
  - name: webhook-secret
    value: webhook-secret
  - name: message
    value: "Hello from Tekton!"
  - name: bot-name
    value: "Tekton Bot"
  - name: avatar-url
    value: "https://github.com/tektoncd.png"

```
