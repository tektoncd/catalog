## Generate a version from git history

The `git-version` task let you generate a version from git history using `https://gitversion.net/`

### Install the Task

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/git-version/0.1/raw
```

## Workspaces

* **source**: A workspace with a checked out git repository.

### Parameters

* **branch:**: The branch to checkout to create a version for e.g. "develop"

## Results

* **gitVersion**: The calculated git version you could use for git tagging e.g. "0.1.0-tektonize.1-188"
* **packageVersion**: A normalized version for use in container images e.g. "0.1.0-tektonize.1-188"

## Usage

You will need to make sure the used workspace has a git clone with all the history available.
Git clone with a depth of "0" is therefore needed.

## Platforms

The Task can be run on `linux/amd64` platform.
