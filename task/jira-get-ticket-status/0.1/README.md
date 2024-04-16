# Jira - Get Ticket Status

This task helps you to get the current status of a Jira ticket.

## Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/jira-get-ticket-status/0.1/raw
```

## Parameters

* **ticket_id:** Jira Ticket ID.
* **ssl_verify:** Verify or not SSL certificates (by default: `true`).
* **secret_name:** The name of the secret that have the Jira URL and the Bearer token.

## Results

* **ticket_status**: Current Jira Ticket status

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

This Task implements a `Secret`to provide the required **Bearer Token** to authenticate with Jira platform. For example:

```yaml
# Complete the fields indicated below
kind: Secret
apiVersion: v1
metadata:
  name: jira-config
stringData:
  JIRA_BEARER_TOKEN: #{BEARER_TOKEN}
  JIRA_URL: #{JIRA_PLATFORM_URL}
type: Opaque
```

Then, to use it in a `Pipeline` only reference this Task properly:
```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: example-jira-pipeline
spec:
  tasks:
    - name: verify-jira-ticket-status
      taskRef:
        name: jira-get-ticket-status
      params:
        - name: ticket_id
          value: 'KAN-3'
        - name: secret_name
          value: jira-config
```
