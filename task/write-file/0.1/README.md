# Write a file to a workspace

This task can be used to write a file onto the output workspace.
Use parameter expansion to insert variable content into the written
file. It can also set specific permissions on the file.

## Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/write-file/0.1/raw
```

## Parameters

- **path**: Relative path to create within the workspace. Directories will be created as necessary. 
- **mode**: chmod-style mode string to apply to the file. Note that mode will not be applied to created directories.
- **contents**: Contents of the file to create. Note that octal numbers need quoting in YAML.

## Platforms

The Task can be run on `linux/amd64`, `linux/s390x`, and `linux/ppc64le` platforms.

## Usage

This example task generates a random password from the pipeline run's unique id.

```yaml
- name: output-credentials
  taskRef:
    name: write-file
    kind: Task
  workspaces:
    - name: output
      workspace: shared-workspace
  params:
    - name: path
      value: ./config/login.ini
    - name: mode
      value: "0400"
    - name: contents
      value: |
        [credentials]
        user = ze-user
        password = $(context.pipelineRun.uid)
```
