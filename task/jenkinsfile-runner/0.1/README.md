# Jenkinsfile-runner Task

Runs a Jenkins Pipeline into tekton using jenkinsfile-runner.
`jenkinsfile-runner` is a headless Jenkins instance able to run `Jenkinsfile`s without requiring a complete Jenkins with its UI.

## Install the Task

```bash
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/task/jenkinsfile-runner/0.1/jenkinsfile-runner.yaml
```

## Parameters

- **JENKINSFILE_URL**: The URL of the Jenkinsfile to run (**Required**)


## Results

- **build_number**: This will output the current jenkins build_number of the job.

## Workspaces

- **source**: In case any file needs to be provided or saved by the Jenkins Job. (_Default_: `emptyDir: {}`)

## Usage

1. Start a job without parameters

   ```yaml
   apiVersion: tekton.dev/v1beta1
   kind: TaskRun
   metadata:
     name: jenkinsfile-runner-job-run
   spec:
     taskRef:
       name: jenkinsfile-runner
     params:
       - name: JENKINSFILE_URL
         value: "https://raw.githubusercontent.com/akram/jenkinsfile-runner-openshift/8470426cc2211dabb0555efaaef0aced59e9b4a3/Jenkinsfile"
     workspaces:
       - name: source
         emptyDir: {}
   ```

