# Trigger Jenkins Job

The following task can be used to trigger a Jenkins job using CURL request from a Tekton Task.

More details on Remote Access API can be found [here](https://www.jenkins.io/doc/book/using/remote-access-api/)

## Install the Task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/trigger-jenkins-job/0.1/raw
```

## Parameters

- **JENKINS_HOST_URL**: The URL on which Jenkins is running (**Required**)
- **JOB_NAME**: The Job name which needs to be triggered (**Required**)
- **JENKINS_SECRETS**: The name of the secret containing the username and API token for authenticating the Jenkins (_Default_: jenkins-credentials) (**Required**)
- **JOB_PARAMS**: Extra parameters which needs to be appended in the `CURL` request. (_Default_: ""). `JOB_PARAMS` is of type `array` so multiple arguments can be appended. `JOB_PARAMS` can be provided as follows:-

  ```yaml
  params:
    - name: JOB_PARAMS
      value: |
        - FILE_LOCATION_AS_SET_IN_JENKINS=@PATH_TO_FILE
  ```

## Workspaces

- **source**: In case any file needs to be provided to the Jenkins Job. (_Default_: `emptyDir: {}`)

## Secrets

Secrets containing `username`,`API token` and `crumb` that are used in the task for making the CURL request.

Crumb can be obtained using following command :-

```bash
$ wget -q --auth-no-challenge --user username --password password --output-document - 'http://${Jenkins_URL}/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)'
```

This will give you something like `Jenkins-Crumb:44e7033af70da95a47403c3bed5c10f8`. Without crumb information, running curl command will result in example errors such as `HTTP/1.1 403 Forbidden` or `Error 403 No valid crumb was included in the request`.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: jenkins-credentials
type: Opaque
stringData:
  username: username
  apitoken: api-token
  crumb: crumb
```

## Usage

1. Without `JOB_PARAMS` parameters

   ```yaml
   apiVersion: tekton.dev/v1beta1
   kind: TaskRun
   metadata:
     name: trigger-jenkins-job-run
   spec:
     taskRef:
       name: trigger-jenkins-job
     params:
       - name: JENKINS_HOST_URL
         value: "http://localhost:8080"
       - name: JOB_NAME
         value: tekton
     workspaces:
       - name: source
         emptyDir: {}
   ```

1. With `JOB_PARAMS` parameters

   ```yaml
   apiVersion: tekton.dev/v1beta1
   kind: TaskRun
   metadata:
     name: trigger-jenkins-job-run
   spec:
     taskRef:
       name: trigger-jenkins-job
     params:
       - name: JENKINS_HOST_URL
         value: "http://localhost:8080"
       - name: JOB_NAME
         value: tekton
       - name: JOB_PARAMS
         value:
           - id=123
           - verbosity=high
     workspaces:
       - name: source
         emptyDir: {}
   ```
