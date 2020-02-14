Send a message via SMTP server

This task sends a simple email to receivers via SMTP server

## Install the Task and create a secret

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/mail/sendmail.yaml
```

Create a secret that has the SMTP server information

* **url**: The IP address of the SMTP server

* **port**: The port number of the SMTP server

* **user**: User name for the SMTP server

* **password**: Password for the SMTP server

* **tls**: The tls enabled or not ("True" or "False")

Example server-secret.yaml
```
kind: Secret
apiVersion: v1
metadata:
  name: server-secret
stringData:
  url: "smtp.server.com"
  port: "25"
  user: "userid"
  password: "password"
  tls: "False"
```

Example kubectl command
```
kubectl apply -f server-secret.yaml
```

## Inputs

### Parameters

* **server**: The name of the secret that has the SMTP server information

* **subject**: Email subject (plain text)

* **body**: Email body (plain text)

* **sender**: Email sender email address

* **recipients**: Email recipients email addresses (space delimited)

## Usage

This TaskRun runs the Task to send an email to the receivers via the SMTP server.

```
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  name: mail-taskrun
spec:
  inputs:
    params:
    - name: server
      value: server-secret
    - name: subject
      value: Hi, again!
    - name: body
      value: "Tekton email"
    - name: sender
      value: "<me@myserver.com>"
    - name: recipients
      value: "<him@hisserver.com> <her@herserver.com>"
  taskRef:
    name: sendmail
```

