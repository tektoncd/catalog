# PWSH - Running Powershell Scripts

The following task helps you to run powershell commands. 

### Install powershell

```bash
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/task/powershell/0.1/powershell.yaml
```

## Parameters

- **tag**: the tag used for the `mcr.microsoft.com/powershell` image (_default_: `latest`)
- **command**: Powershell command
- **verbose**: Verbosity level for command (_default_: `SilentlyContinue`)

## Usage

This `TaskRun` runs `Write-Output 'Hello World'` command using `latest` powershell image and verbose logs enabled.

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: example-powershell
spec:
  taskRef:
    name: powershell
  params:
    - name: command
      value: "Write-Output 'Hello World'; `$random = get-random -Minimum 0 -Maximum 100; write-output 'Created this number for you $random'"
    - name: tag
      value: latest
    - name: verbose
      value: Continue
```
