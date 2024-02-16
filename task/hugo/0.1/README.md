# Hugo

[Hugo](https://github.com/gohugoio/hugo) is a static site generator written in Go.
It is optimized for speed, easy use and configurability. Hugo takes a directory
with content and templates and renders them into a full html website.

This `tekton` task generates a Hugo site. For `0.1` is only supports
hugo [modules](https://gohugo.io/hugo-modules/).

## Installing the Task

You can install the task with the following command:

```bash
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/hugo/0.1/hugo.yaml
```

## Parameters

- **content-dir**: The directory where the content is located. (_default_: `""`)
- **minify**: Minify the output. (_default_: `false`)
- **base-url**: The base URL for the site. (_default_: `""`)
- **verbose**: Print verbose output. (_default_: `false`)

## Workspaces

- **work-dir**: The directory where `hugo` will be run. It should contain the `config.toml` file and the `content` and `layouts` directories.

## Results

- `output`: The directory where the generated site is located.

## Usage

```
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: hugo-task-test-pipeline
spec:
  workspaces:
    - name: work-dir

  tasks:
    - name: fetch-repository
      taskRef:
        name: git-clone
      workspaces:
        - name: output
          workspace: work-dir
      params:
        - name: url
          value: "https://github.com/shipit/hugotenberg.git"
        - name: subdirectory
          value: ""
        - name: deleteExisting
          value: "true"

    - name: build-project
      runAfter:
        - fetch-repository
      taskRef:
        name: hugo
      workspaces:
        - name: work-dir
          workspace: work-dir
```

## Platforms

The Task can be run on `linux/amd64` platform.
