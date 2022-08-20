# Robot Framework

This task runs [Robot Framework](https://robotframework.org/) tests that are provided in the source workspace. Additional configuration is possible with a [variable file](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#resource-and-variable-files).

## Install the Task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/robot-framework/0.1/raw
```

## Workspaces

- source: A workspace containing Robot Framework tests. Results are written to `/reports`.

- variables-file: An optional workspace to add a variable file. Useful if you have want to use a secret for credentials, url's, etc.

## Parameters

- **IMAGE**: Optional: Default uses a basic python image and installs test requirements during runtime. It's also possible to use your own image which has requirements pre-installed.
- **REQUIREMENTS_FILE**: Optional: Requirements file to use for installing test requirements
- **ROBOT_OPTIONS**: Optional: Arguments to use with the robot command
- **TEST_DIR**: Directory that contains robot tests
- **VARIABLES_FILE**: Optional: Name of the variable file provided in the workspace. A .py extension is necessary.

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

Basic usage without installing extra requirements or using a variables file:

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: example-run
spec:
  taskRef:
    name: robot-framework
  params:          
    - name: TEST_DIR
      value: ./rf-tests
  workspaces:
  - name: source
    persistentVolumeClaim:
      claimName: my-source
```

Using a secret that contains a variable file (called `variables.py`):

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: example-run
spec:
  taskRef:
    name: robot-framework
  params:          
    - name: TEST_DIR
      value: ./rf-tests
    - name: VARIABLES_FILE
      value: variables.py
  workspaces:
  - name: source
    persistentVolumeClaim:
      claimName: my-source
  - name: variables-file
    secret:
      secretName: variables
```

Result files are written to `/reports` in the source workspace. If you want to store the files long-term make sure to upload them to S3 or something similar.