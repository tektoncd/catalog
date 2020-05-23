# Git SSH Auth

## Configuration of SSH with GitHub as example

Prepare secrets for SSH authentication.

### Prepare `known_hosts` file
Example using github.com

1. Create file with `known_hosts` (you may also want to verify this further)

   ```
   ssh-keyscan github.com > ssh_known_hosts
   ```

2. Create secret from file

    ```
    kubectl create secret generic github-known-hosts --from-file=ssh_known_hosts
    ```
   
### Generate and distribute SSH key pair
Generate a separate SSH key pair for Tekton

1. Generate keypair to local file

    ```
    ssh-keygen -t rsa -b 4096 -f id_rsa -q -N ""
    ```

2. Create a secret from the private key

   ```
   kubectl create secret generic github-private-key --from-file=id_rsa
   ```
   
3. Upload the public key `id_rsa.pub` to GitHub

   Start with copying the content of the public key with

   ```
   pbcopy < id_rsa.pub
   ```
   
   And follow [Adding a new SSH key to your GitHub account](https://help.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account)


## Example Pipeline

```
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: pipeline-with-git-clone
spec:
  params:
  - name: git-url
    type: string
    description: Url to git repo
  tasks:
  - name: git-clone
    taskRef:
      name: git-clone-ssh
    params:
    - name: url
      value: "$(params.git-url)"
    workspaces:
    - name: output
      workspace: ws
  workspaces:
  - name: ws
```

An example `PipelineRun` for triggering a `git clone`

```
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  generateName: git-clone-ssh-
spec:
  params:
  - name: git-url
    value: git@github.com:jlpettersson/myapp.git    # example GitHub repo url
  pipelineRef:
    name: pipeline-with-git-clone
  workspaces:
  - name: ws
    volumeClaimTemplate:
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 1Gi
  taskRunSpecs:
  - pipelineTaskName: git-clone         # name of task in the Pipeline
    taskPodTemplate:
      volumes:
      - name: ssh-auth                  # name of volume - matching name in Task
        projected:
          defaultMode: 0400
          sources:
          - secret:
              name: github-known-hosts  # name of Secret from Auth setup
          - secret:
              name: github-private-key  # name of Secret from Auth setup
```