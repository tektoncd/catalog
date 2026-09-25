# `notify-matrix`

The `notify-marix` `Task` sends messages to a [Matrix](https://matrix.org/) room on its corresponding endpoint.

## Parameters 

This `Task` has the following required inputs:

1. **`matrix-secret`**: the name of a secret, containing a valid matrix access token (see below)
2. **`room`**: the matrix roomID where the notification will be sent, in the format `#ROOM_NAME:SERVER_NAME`
3. **`endpoint`**: URI of the matrix server to connect and send the message from
4. **`message`**: the message to be sent

## Setting up the `matrix-secret`

In order for the task to be able to send a message to the selected matrix room, make sure you create a secret, of type generic. It should contain a key `token`, containing the access token to the matrix endpoint.

Ex: 
```yaml
kind: Secret
apiVersion: v1
metadata:
  name: matrix-access-token
stringData:
  token: {OAuth token for the user/bot with access to the room}
```

### Obtaining a Matrix `access_token`

First, create a Matrix user with one of the Matrix servers. 

Once the registration process is done, start by setting the 3 following variables:
* `MATRIX_USER`: username you just registered with
* `PASSWORD`: corresponding password
* `MATRIX_ENDPOINT`: Matrix server on which you registered the user

Then, you can get the `access_token` through a simple login API call:
```bash= 
curl -XPOST -d "{\"type\":\"m.login.password\", \"user\":\"$MATRIX_USER\", \"password\":\"$PASSWORD\"}" "https://$MATRIX_ENDPOINT/_matrix/client/r0/login"
{"user_id":"@my.user:matrix.endpoint","access_token":"syt_c2hlcmluZS5raG91cnk_NFpzzGCtxFAHEDVKhYTl_123456","home_server":"matrix.endpoint","device_id":"CNYGHLSLQY","well_known":{"m.homeserver":{"base_url":"https://matrix-client.matrix.org/"}}}
```

With the `access_token` in the output, you can create the secret of type generic with a single key, `token`, containing the `access_token` you just obtained above.

## Platforms

The Task can be run on `linux/amd64`, `linux/s390x`, `linux/386`, and `linux/ppc64le` platforms.

## Usage

[This TaskRun](./samples/notify-matrix-run.yaml) demonstrate usage of the notify-matrix Task.

