# Git Task

This `Task` is Git task to work with repositories used by other tasks
in your Pipeline.

## `git-cli`

This [task](../0.3/git-cli.yaml) can be used to perform `git operations`.
All git commands can be found [here](https://git-scm.com/docs).

Command that needs to be run can be passed as a script to the task.

### Workspaces

* **source**: A workspace that contains the fetched git repository.
* **input**: An optional workspace that contains the files that need to be added to git. You can
    access the workspace from your script using `$(workspaces.input.path)`, for instance:

      cp $(workspaces.input.path)/file_that_i_want .
      git add file_that_i_want
      # etc

* **ssh-directory**: An optional workspace to provide SSH credentials. At
  minimum this should include a private key but can also include other common
  files from `.ssh` including `config` and `known_hosts`. It is **strongly**
  recommended that this workspace be bound to a Kubernetes `Secret`.
  For details on the correct format of the files in this Workspace
  see [Using SSH credentials](#using-ssh-credentials) below.

* **basic-auth**: An optional workspace containing `.gitconfig` and
  `.git-credentials` files. This allows username/password/access token to be
  provided for basic auth.

  It is **strongly** recommended that this workspace be bound to a Kubernetes
  `Secret`. For details on the correct format of the files in this Workspace
  see [Using basic-auth Credentials](#using-basic-auth-credentials) below.

### Parameters

* **BASE_IMAGE**: The base image for the task.
(_default_: `alpine/git:latest`)
* **GIT_USER_NAME**: Git user name for performing git operation.
* **GIT_USER_EMAIL**:  Git user email for performing git operation.
* **GIT_SCRIPT**: The git script to run. (_required_)
* **VERBOSE**: Log the commands that are executed during `git-cli`'s operation. (_default_: true)
* **USER_HOME**: The user's home directory. Set this explicitly if you are running the image as a non-root user. (_default_: "/root")

### Results

* **commit**: The precise commit SHA after git operation is performed.

### Platforms

The Task can be run on `linux/amd64`, `linux/s390x` and `linux/ppc64le` platforms.

### Usage

This task needs authentication to git in order to push after the git operation.

After creating the task, you should now be able to execute `git` commands by
specifying the command you would like to run as the `GIT_SCRIPT` param.

`Example`:

```yaml
  params:
    - name: GIT_SCRIPT
      value: |
        git init
        git remote add origin https://github.com/kelseyhightower/nocode
        git pull origin master
```

## Using SSH credentials

This Task supports fetching private repositories using SSH credentials.

If you are a bit rusty on your SSH and don't know what a typical .ssh directory should look like,
there are tons of good guides to be found online, see for instance [this article by Digital Ocean](https://www.digitalocean.com/community/tutorials/ssh-essentials-working-with-ssh-servers-clients-and-keys).

1. Bind an `ssh-directory` workspace to this Task.
The workspace should contain private keys (e.g. `id_rsa`), `config`
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
      - name: use-git-cli
        taskRef:
          name: git-cli
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
    the `git-cli` Task will blindly accept the remote server's identity.

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
