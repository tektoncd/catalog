# `git-clone`

**Please Note: this Task is only compatible with Tekton Pipelines versions 0.21.0 and greater!**

This `Task` has two required inputs:

1. The URL of a git repo to clone provided with the `url` param.
2. A Workspace called `output`.

The `git-clone` `Task` will clone a repo from the provided `url` into the
`output` Workspace. By default the repo will be cloned into the root of
your Workspace. You can clone into a subdirectory by setting this `Task`'s
`subdirectory` param. If the directory where the repo will be cloned is
already populated then by default the contents will be deleted before the
clone takes place. This behaviour can be disabled by setting the
`deleteExisting` param to `"false"`.

## Workspaces

* **output**: A workspace for this Task to fetch the git repository in to.
* **ssh-directory**: An optional workspace to provide SSH credentials. At
  minimum this should include a private key but can also include other common
  files from `.ssh` including `config` and `known_hosts`. It is **strongly**
  recommended that this workspace be bound to a Kubernetes `Secret`.
* **basic-auth**: An optional workspace containing `.gitconfig` and
  `.git-credentials` files. This allows username/password/access token to be
  provided for basic auth.

  It is **strongly** recommended that this workspace be bound to a Kubernetes
  `Secret`. For details on the correct format of the files in this Workspace
  see [Using basic-auth Credentials](#using-basic-auth-credentials) below.

  **Note**: Settings provided as part of a `.gitconfig` file can affect the
  execution of `git` in ways that conflict with the parameters of this Task.
  For example, specifying proxy settings in `.gitconfig` could conflict with
  the `httpProxy` and `httpsProxy` parameters this Task provides. Nothing
  prevents you setting these parameters but it is not advised.

## Parameters

* **url**: Repository URL to clone from. (_required_)
* **revision**: Revision to checkout. (branch, tag, sha, ref, etc...) (_default_: "")
* **refspec**: Refspec to fetch before checking out revision. (_default_:"")
* **submodules**: Initialize and fetch git submodules. (_default_: true)
* **depth**: Perform a shallow clone, fetching only the most recent N commits. (_default_: 1)
* **sslVerify**: Set the `http.sslVerify` global git config. Setting this to `false` is not advised unless you are sure that you trust your git remote. (_default_: true)
* **subdirectory**: Subdirectory inside the `output` workspace to clone the repo into. (_default:_ "")
* **deleteExisting**: Clean out the contents of the destination directory if it already exists before cloning. (_default_: true)
* **httpProxy**: HTTP proxy server for non-SSL requests. (_default_: "")
* **httpsProxy**: HTTPS proxy server for SSL requests. (_default_: "")
* **noProxy**: Opt out of proxying HTTP/HTTPS requests. (_default_: "")
* **verbose**: Log the commands that are executed during `git-clone`'s operation. (_default_: true)
* **sparseCheckoutDirectories**: which directories to match or exclude when performing a sparse checkout (_default_: "")
* **gitInitImage**: The image providing the git-init binary that this Task runs. (_default_: "gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/git-init:TODO")
* **userHome**: The user's home directory. Set this explicitly if you are running the image as a non-root user. (_default_: "/tekton/home")

## Results

* **commit**: The precise commit SHA that was fetched by this Task
* **url**: The precise URL that was fetched by this Task

## Usage

If the `revision` is not provided in the param of the taskrun
then it will auto-detect the branch as specified by the `default`
in the respective git repository.

The following pipelines demonstrate usage of the git-clone Task:

- [Cloning a branch](./samples/git-clone-checking-out-a-branch.yaml)
- [Checking out a specific git commit](./samples/git-clone-checking-out-a-commit.yaml)
- [Checking out a git tag and using the "commit" Task Result](./samples/using-git-clone-result.yaml)

## Cloning Private Repositories

This Task supports fetching private repositories. There are two ways to
authenticate:

1. The simplest approach is to bind an `ssh-directory` workspace to this
Task. The workspace should contain private keys (e.g. `id_rsa`), `config`
and `known_hosts` files - anything you need to interact with your git remote
via SSH. It's **strongly** recommended that you use Kubernetes `Secrets` to
hold your credentials and bind to this workspace.

    In a TaskRun that would look something like this:

    ```yaml
    kind: TaskRun
    spec:
      workspaces:
      - name: ssh-directory
        secret:
          secretName: my-ssh-credentials
    ```

    And in a Pipeline and PipelineRun it would look like this:

    ```yaml
    kind: Pipeline
    spec:
      workspaces:
      - name: ssh-creds
      # ...
      tasks:
      - name: fetch-source
        taskRef:
          name: git-clone
        workspaces:
        - name: ssh-directory
          workspace: ssh-creds
      # ...
    ---
    kind: PipelineRun
    spec:
      workspaces:
      - name: ssh-creds
        secret:
          secretName: my-ssh-credentials
      # ...
    ```

    The `Secret` would appear the same in both cases - structured like a `.ssh`
    directory:

    ```yaml
    kind: Secret
    apiVersion: v1
    metadata:
      name: my-ssh-credentials
    data:
      id_rsa: # ... base64-encoded private key ...
      known_hosts: # ... base64-encoded known_hosts file ...
      config: # ... base64-encoded ssh config file ...
    ```

    Including `known_hosts` is optional but strongly recommended. Without it
    the `git-clone` Task will blindly accept the remote server's identity.

2. Use Tekton Pipelines' built-in credentials support as [documented in
Pipelines' auth.md](https://github.com/tektoncd/pipeline/blob/master/docs/auth.md).

## Running as a Non-Root User

The `git-init` image that this Task utilizes offers a built in nonroot
user. In combination with support from other Tasks this allows your
Pipelines to run without needing root permissions. There are some extra
steps you'll need to take for this to work:

- In the security context for the Task make sure you're using UID 65532.

    In a TaskRun that looks like this:

    ```yaml
    kind: TaskRun
    spec:
      podTemplate:
        securityContext:
          runAsNonRoot: true
          runAsUser: 65532
    ```

    And in a PipelineRun it looks like this:

    ```yaml
    kind: PipelineRun
    spec:
      taskRunSpecs:
      - pipelineTaskName: footask # ...your git-clone PipelineTask name...
        taskPodTemplate:
          securityContext:
            runAsNonRoot: true
            runAsUser: 65532
    ```

- Make sure to provide the `userHome` param and set it to nonroot's
home directory:

    ```yaml
    params:
    - name: userHome
      value: /home/nonroot
    ```

Once these two modifications are in effect you should now see your
`git-clone` Task run as nonroot. The files cloned on to the `output`
workspace will end up owned by user 65532.

## Using basic-auth Credentials

**Note**: It is strongly advised that you use `ssh` credentials when the
option is available to you before using basic auth.

To support basic-auth this Task exposes an optional `basic-auth` Workspace.
The bound Workspace must contain a `.gitconfig` and `.git-credentials` file.
Any other files on this Workspace are ignored. A typical `Secret` containing
these credentials looks as follows:

```yaml
kind: Secret
apiVersion: v1
metadata:
  name: my-basic-auth-secret
type: Opaque
stringData:
  .gitconfig: |
    [credential "https://<hostname>"]
      helper = store
  .git-credentials: |
    https://<user>:<pass>@<hostname>
```
