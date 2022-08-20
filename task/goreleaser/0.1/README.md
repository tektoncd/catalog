# GoReleaser

[GoReleaser](https://github.com/goreleaser/goreleaser) builds Go binaries for several platforms, creates a GitHub release and then pushes a Homebrew formula to a tap repository.

## Installing the Task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/goreleaser/0.1/raw
```

## Parameters

- **package**: Base package to build and release. (Required)
- **github-token-secret**: Name of the secret holding the github-token. (_Default_: `bot-token-github`)
- **github-token-secret-key**: Name of the secret key holding the github-token. (_Default_: `bot-token`)
- **flags**: Flags to pass to `goreleaser release`. (_Default_: `--timeout=30m`)

## Workspaces

- **source**: The workspace containing the Go source code which needs to be released. The default `mountPath` is `/workspace/src/$(params.package)`

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

1. Create the GitHub token by following the steps from [here](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token)

2. Create the Secret

```bash
kubectl create secret generic bot-token-github --from-literal=bot-token=${github_token}
```

3. Create the Pipeline and PipelineRun

```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: gorelease-pipeline
spec:
  workspaces:
    - name: shared-workspace
  params:
    - name: url
      description: git url to clone
    - name: revision
      description: revision branch to checkout
    - name: package
      description: package to release
      default: github.com/tektoncd/cli
    - name: github-token-secret
      description: name of the secret holding the github-token
      default: bot-token-github
    - name: github-token-secret-key
      description: name of the key for the secret holding the github-token
      default: bot-token
  tasks:
    - name: fetch-repository
      taskRef:
        name: git-clone
      workspaces:
        - name: output
          workspace: shared-workspace
      params:
        - name: url
          value: $(params.url)
        - name: revision
          value: $(params.revision)
        - name: deleteExisting
          value: "true"
    - name: release
      runAfter:
        - fetch-repository
      taskRef:
        name: goreleaser
      params:
        - name: package
          value: $(params.package)
        - name: github-token-secret
          value: $(params.github-token-secret)
        - name: github-token-secret-key
          value: $(params.github-token-secret-key)
      workspaces:
        - name: source
          workspace: shared-workspace
---
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  generateName: gorelease-pipeline-run
spec:
  pipelineRef:
    name: gorelease-pipeline
  workspaces:
    - name: shared-workspace
      volumeClaimTemplate:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 500Mi
  params:
    - name: revision
      value: "v1.1.1"
    - name: url
      value: https://github.com/tektoncd/cli
```
