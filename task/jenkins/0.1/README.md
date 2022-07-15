# Jenkins Task

The following task can be used to interact with Jenkins using the Jenkins REST API.

More details on Remote Access API can be found [here](https://www.jenkins.io/doc/book/using/remote-access-api/)

## Install the Task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/jenkins/0.1/raw
```

## Parameters

- **JENKINS_HOST_URL**: The URL on which Jenkins is running (**Required**)
- **JENKINS_SECRETS**: The name of the secret containing the username and API token for authenticating the Jenkins (_Default_: jenkins-credentials) (**Required**)
- **ARGS**: Extra arguments to add to the control script. (**Required**)

The arguments are :

1. `start`: Start a new Jenkins job.

```
start [--file-to-upload FILE_TO_UPLOAD] [--wait-started] [--wait-finished] job [job_parameters [job_parameters ...]]
positional arguments:
  job - The job name
  job_parameters - Optional: The parameters to add i.e: key=value

optional arguments:
  --file-to-upload FILE_TO_UPLOAD
                        The path of the file to upload to job.
  --wait-started        Wether to wait for the job to be started.
  --wait-finished       Wether to wait for the job to be finished.
```

`log`: Get log of a jenkins build.

```
log [-h] [--output-file OUTPUT_FILE] job [build_number]

positional arguments:
  job - The job name
  build_number - The build number, use 'lastBuild' to get the latest build

optional arguments:
  --output-file OUTPUT_FILE
                        The location where to save logs on the filesystem. (i.e: a workspace location)
```

## Results

- **build_number**: This will output the current jenkins build_number of the job.

## Workspaces

- **source**: In case any file needs to be provided or saved by the Jenkins Job. (_Default_: `emptyDir: {}`)

## Secrets

Secrets containing `username`,`API token` that are used in the task for making the REST API request.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: jenkins-credentials
type: Opaque
stringData:
  username: username
  apitoken: api-token
```

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

1. Start a job without parameters

   ```yaml
   apiVersion: tekton.dev/v1beta1
   kind: TaskRun
   metadata:
     name: jenkins-job-run
   spec:
     taskRef:
       name: jenkins
     params:
       - name: JENKINS_HOST_URL
         value: "http://localhost:8080"
       - name: ARGS
         value: ["start",  "job"]
     workspaces:
       - name: source
         emptyDir: {}
   ```

1. Start job with the parameters `param=value` and wait that it finishes.

   ```yaml
   apiVersion: tekton.dev/v1beta1
   kind: TaskRun
   metadata:
     name: jenkins-job-run
   spec:
     taskRef:
       name: jenkins
     params:
       - name: JENKINS_HOST_URL
         value: "http://localhost:8080"
       - name: ARGS
         value: ["start",  "--wait-finished", "test", "param=value"]
     workspaces:
       - name: source
         emptyDir: {}
   ```
