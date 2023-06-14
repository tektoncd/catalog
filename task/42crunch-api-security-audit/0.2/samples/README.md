# 42Crunch REST API Static Security Testing sample

## Quick start

### Create sample pipeline and related resources

- Update `git-secret.yaml` with your GIT credentials, to access your source control repository

- Update `secret.yaml` with your 42Crunch API Token

- Update `pipeline-run.yaml` setting the relevant parameters to configure your source control repository URL, etc.

### Execute the pipeline

Run these commands to create and execute the pipeline:

```sh
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/git-clone/0.6/raw

kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/42crunch-api-security-audit/0.1/raw


kubectl apply -f secret.yaml
kubectl apply -f git-secret.yaml
kubectl apply -f pipeline.yaml
kubectl apply -f pipeline-run.yaml
```
