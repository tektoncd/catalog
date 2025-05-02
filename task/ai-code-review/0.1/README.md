# AI Code Review Task

This Tekton Task enables automated code reviews using AI models. It fetches pull request details and code diffs from GitHub, analyzes the changes, and posts AI-generated review comments back to the PR. It is designed to work with any LLM API compatible with the OpenAI format.

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/ai-code-review/0.1/raw
```

## Parameters

- name: repo
  description: GitHub repository in format owner/repo
  type: string

- name: pullRequestNumber
  description: Pull request number to review
  type: string

- name: githubHost
  description: GitHub API host URL
  type: string
  default: "https://api.github.com"

- name: apiBaseUrl
  description: Base URL for the AI API service
  type: string
  default: "https://api.openai.com/v1"

- name: apiModel
  description: AI model to use for code review
  type: string
  default: "gpt-3.5-turbo"

- name: excludePatterns
  description: Comma-separated list of file patterns to exclude from review
  type: string
  default: "*.md,*.txt,package-lock.json,yarn.lock"

- name: dryRun
  description: Whether to actually post comments or just print them
  type: string
  default: "false"

- name: debug
  description: Debug mode
  type: string
  default: "false"

## Workspaces

- shared-workspace: Workspace to share the source code and Python virtual environment


## Secrets

You need a Kubernetes Secret with the following keys:

- github-token: GitHub token with access to the target repo
- api-key: Token for the OpenAI-compatible API

## Platforms

This Task can be run on the linux/amd64 platform.

## Usage

- Mount the repository into shared-workspace.
- Reference your code-review-secrets in the TaskRun or PipelineRun.

Example TaskRun snippet:
```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  generateName: ai-code-review-run-
spec:
  taskRef:
    name: ai-code-review
  params:
    - name: repo
      value: "jkhelil/go-helloworld"
    - name: pullRequestNumber
      value: "19"
    - name: githubHost
      value: "https://api.github.com"
    - name: apiBaseUrl
      value: "https://granite-3-1-8b-instruct--apicast-staging.apps.int.stc.ai.prod.us-east-1.aws.paas.redhat.com:443/v1"
    - name: apiModel
      value: "/data/granite-3.1-8b-instruct"
    - name: excludePatterns
      value: "*.md,*.txt,package-lock.json,yarn.lock,*.png,*.jpg"
    - name: dryRun
      value: "false"
    - name: debug
      value: "true"
  workspaces:
  - name: shared-workspace
    emptyDir: {}

```
