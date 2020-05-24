# Post a message to telegram

These tasks post a simple message to a telegram chat.

# send-to-telegram

This task uses the Bot API of telegram to send a message.
Create a bot as decribed over [here](https://core.telegram.org/bots).

## Install the Task and create a secret

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/telegrammessage/send-to-telegram.yaml
```

Create a secret that has bot token.

Example telegram-bot-token-secret.yaml
```
kind: Secret
apiVersion: v1
metadata:
  name: telegram-bot-token-secret
stringData:
  token: {token over here}
```

Example kubectl command
```
kubectl apply -f telegram-bot-token-secret.yaml
```

## Parameters

* **bot-token-secret**: The name of the secret that has the bot token.

* **message**: Plain text message to be posted in the chat.

* **chat-id**: The ID of the chat to send the message towards. See telegram documentation to get the correct ID.

## Usage

This TaskRun runs the Task to post a message to the the chat channel.

```
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: run-send-to-telegram
spec:
  params:
  - name: bot-token-secret
    value: telegram-bot-token-secret
  - name: message
    value: "Hello from Tekton!"
  - name: chat-id
    value: "<your chat ID over here>"
  taskRef:
    name: send-to-telegram

```
