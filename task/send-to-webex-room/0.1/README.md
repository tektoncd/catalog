# Post a message to Webex room

This task posts a simple text message to a Webex room.

# send-to-webex-room

This task uses the Messages API of Webex to send a text message.
Create a bot as decribed over [here](https://developer.webex.com/docs/bots).

## Install the Task and create a secret

```bash
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/task/send-to-webex-room/0.1/send-to-webex-room.yaml
```

Create a secret that has the Webex API bot token.

Example webex-token-secret.yaml
```yaml
kind: Secret
apiVersion: v1
metadata:
  name: webex-token-secret
stringData:
  token: {place token of Bot}
```

Example kubectl command
```bash
kubectl apply -f webex-token-secret.yaml
```

## Parameters

* **webex-token-secret-name**: The name of the secret which has the Webex Bot token.

* **message**: Plain text message to be posted in the chat.

* **room-id**: The ID of the room to send the message. See [official documentation](https://developer.webex.com/docs/api/v1/rooms/list-rooms) or [medium article](https://medium.com/@ObjectIsAdvantag/everything-you-always-wanted-to-know-about-the-spark-room-id-june16-550a0e65c59d) for help to find your ID.

## Usage

Example Tekton CLI command
```bash
tkn task start send-to-webex-room -p webex-token-secret-name=webex-token-secret -p room-id=test -p message=test
```

This TaskRun runs the Task to post a message to a Webex room.

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: run-send-to-webex
spec:
  params:
  - name: webex-token-secret-name
    value: webex-token-secret
  - name: message
    value: "Hello from Tekton!"
  - name: room-id
    value: "<your target room ID>"
  taskRef:
    name: send-to-webex-room
```
