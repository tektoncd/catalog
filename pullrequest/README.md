# Generic PullRequest interaction

This Task allows a user to interact with an SCM (source control management) system through an abstracted interface
(implemented uisng [jenkins-x/go-scm](https://github.com/jenkins-x/go-scm)).

* [Install the Task](#install-the-tasks)
* [Configure the Task](#configure-the-tasks)
* [Usage](#usage)
* [PullRequest Image](#pullrequest-image)

_This `Task` works with both public SCM instances and self-hosted/enterprise GitHub/GitLab instances. For a GitHub specific `Task` see [github](../github)._

## Mode: Upload or Download

In `download` mode, this `Task` will look at the state of an existing pull request and populate
[the `pr` workspace](#workspaces) with the state of the pull request, including
the `.MANIFEST` file.

If you want to update or delete existing attributes of a PR, running `download`
first will allow you to use `upload` to make those changes.

In `upload` mode, this `Task` will look at the contents of [the `pr` workspace](#workspaces)
and compare it to the `.MANIFEST` file (if it exists). Any differences will result
in requests being made to bring the Pull Request into the state described in the
workspace.

## Install the Tasks

To install the Task:

```bash
kubectl apply -f pullrequest/pr.yaml
```

## Configuring the Tasks

### Parameters

* `mode` (_Required_)- The [mode ("upload" or "download")](#mode-upload-or-download)
* `url` (_Required_) - The complete URL of the Pull Request, e.g. `https://github.com/bobcatfish/catservice/pull/16`
* `provider` (_Required_) - The type of SCM system, currently `github` or `gitlab`
* `secret-key-ref` (_Required_) - The name of a secret key containing
  [the token required for SCM requests](#permissions)
* `insecure-skip-tls-verify` (_Default: `"false"`_) - If `"true"`, certificate validation will be disabled

### Workspaces

The `pr` workspace holds all the data about any labels, statuses, comments you want to update.

The files in the `pr` workspace represent the state of [the configured PR](#parameters),
i.e. the current state when using [download mode](#mode-uploapr-sample-add-comment-q26vrd-or-download) and/or
the desired state when using [upload mode](#mode-upload-or-download).

The structure of the workspace is:

* `/labels/<label>` - These are empty files, the name of the file is the name of the label
  (URL encode non-URL safe characters).
* `/status/<status>` - These are [json files that represent statuses](#statuses)
* `/comments/<comment>` - These are [json files that represent comments](#comments)
* `base.json` - Information about the base commit of the PR
* `head.json` - Information about the head commit of the PR
* `pr.json` - Information about the PR

When populated via [download](#mode-upload-or-download), the file `.MANIFEST` is
populated and used to represent the current state of the Pull Request; before
[upload](#mode-upload-or-download) mutates the the Pull Request it will compare
the contents of the `pr` workspace to this file to determine what has changed.

_See [pr-example](.pr-example) for an example of a `pr` workspace poulated with comments, labels,
and statuses (.MANIFEST file not included)._

##### statuses

Each status file is a json file containing a dictionary with the following keys:

* `Label`: The name of the status
* `Desc`: (_optional_) A string to associate with the current state of the status
* `Target`: (_optional_) A link to where more information can be found (e.g. link to logs)
* `State`: The state of the status, [valid options](https://github.com/jenkins-x/go-scm/blob/68aae24e07bc56f684a2f2b9da451b2386ca8545/scm/const.go#L29-L50) are:
  * `unknown`
  * `pending`
  * `running`
  * `success`
  * `failure`
  * `cancelled`
  * `expected`
  * `error`

```json
{
  "State": "pending",
  "Label": "pull-tekton-pipeline-build-tests",
  "Desc": "Job triggered.",
  "Target": "https://tekton-releases.appspot.com/build/tekton-prow/pr-logs/pull/tektoncd_pipeline/995/pull-tekton-pipeline-build-tests/1146102490727452672/"
}
```

_See [pr-example/status](.pr-example/status) for examples._

##### comments

The format of the files in `comments` depends on whether
[upload or download mode is being used](#modes-upload-or-download).

_[pipeline#2168](https://github.com/tektoncd/pipeline/issues/2168)_

###### upload mode comments

When uploading comments, the content of the file is used as the body of the comment.

###### download mode comments

Each comment file is a json file containing a dictionary that represents a comment
in a vendor agnostic way [with these keys](https://github.com/jenkins-x/go-scm/blob/68aae24e07bc56f684a2f2b9da451b2386ca8545/scm/issue.go#L54-L61):

* `ID` - Identifier of the comment
* `Body` - Body of the comment
* `Link` - URL that links to the comment
* `Created` - [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) conforming string
* `Updated` - [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) conforming string
* `Author` - Another dictionary representing the user who made the comment
  [with the _optional_ keys](https://github.com/jenkins-x/go-scm/blob/68aae24e07bc56f684a2f2b9da451b2386ca8545/scm/user.go#L14-L22)
  * `Login` - User's handle
  * `Name` - User's name
  * `Email` - User's email
  * `Avatar` - Link to user's avatar image
  * `Link` - Link to user's profile
  * `Created` - [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) conforming string
  * `Updated` - [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) conforming string

_See [pr-example/comments](.pr-example/comments) for examples of GitHub comments._

## Usage

### Permissions

The Task will need access to an opaque secret containing a token to use when making
requests to the SCM provider (configured via [the `secret-key-ref` param](#parameters)).
The secret is expected to contain a key called `token` which contains the auth token as a
base64 encoded string, for example:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: github-auth-token
type: Opaque
data:
  token: dG9rZW4=
```

### Running the Task

Example `TaskRun` that would run this `Task` in [download mode](#modes-upload-or-download):

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  generateName: some-task-run-
spec:
  taskRef:
  - name: pull-request
  workspaces:
  - name: pr
    persistentVolumeClaim:
      claimName: shared-task-storage
  params:
  - name: mode
    value: download
  - name: url
    value: https://github.com/bobcatfish/catservice/pull/16
  - name: provider
    value: github
  - name: secret-key-ref
    value: some-secret
```

[sample/add-comment.yaml](sample/add-comment.yaml) contains an example of a `PipelineRun`
which creates a `Pipeline` to exercise this Task's upload and download functionality.

To try out the sample (note that it expects the existence of a [secret](#permissions) called
'webhook-secret`):

```bash
kubectl apply -f pullrequest/sample/static.yaml
kubectl create -f pullrequest/sample/add-comment.yaml
```

## PullRequest Image

This Task was created to have feature parity with
[the Tekton Pipelines PullRequest PipelineResource](https://github.com/tektoncd/pipeline/blob/master/docs/resources.md#pull-request-resource)
and uses [the pullrequest-init image](https://github.com/tektoncd/pipeline/tree/master/cmd/pullrequest-init)
which is built and published as part of [Tekton Pipeline releases](https://github.com/tektoncd/pipeline/releases).