# Rsync

This task provides synchronization of files between container and remote host. It relies on rsync and sshpass commands to implement.

## Install the Task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/rsync/0.1/raw
```

## Workspaces

- source: A workspace for this Task to sync files.

- ssh-directory: An workspace to provide SSH credentials.

## Parameters

- **direction**: "local-to-remote" means synchronization from the container to the remote host, and "remote-to-local" means synchronization from the remote host to the container. (_default:_ "local-to-remote")
- **local-path**: The directory in the container that you want to synchronize (_default:_ "./")
- **remote-path**: The directory in the remote host that you want to synchronize (_default:_ "~/")
- **remote-ip**: IP of the remote host (_default:_ "0.0.0.0").
- **remote-username**: Username of the remote host. (_default:_ "root")

## Usage

- Install rsync and sshpass in remote host

```bash
yum install -y rsync sshpass
```

- Create SSH credentials

```bash
kubectl create secret generic rsync-ssh-credentials \
  --from-file=id_rsa=/root/.ssh/id_rsa
```

- Create the `PipelineRun`

```yaml
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: rsync-remote-to-local-by-ssh
spec:
  pipelineSpec:
    workspaces:
      - name: workspace
      - name: ssh-creds
    tasks:
      - name: rsync-files
        taskRef:
          name: rsync
        params:
          - name: direction
            value: "remote-to-local"
          - name: local-path
            value: "."
          - name: remote-ip
            value: "chenshaowen.com"
          - name: remote-username
            value: "shaowenchen"
          - name: remote-path
            value: "/Users/shaowenchen/Downloads/rsync/"
        workspaces:
          - name: source
            workspace: workspace
          - name: ssh-directory
            workspace: ssh-creds
      - name: verify
        taskSpec:
          workspaces:
            - name: source
          steps:
            - name: shell
              image: alpine
              workingDir: $(workspaces.source.path)
              script: |
                #!/bin/sh
                pwd
                ls -al
        workspaces:
          - name: source
            workspace: workspace
        runAfter:
          - rsync-files
  workspaces:
    - name: workspace
      volumeClaimTemplate:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 100M
    - name: ssh-creds
      secret:
        secretName: rsync-ssh-credentials
```

- Output

```bash
$ tkn pipelinerun logs 

? Select pipelinerun: rsync-remote-to-local-by-ssh started 20 minutes ago
[rsync-files : rsync] + '[' true '=' true ]
[rsync-files : rsync] + cp -R /workspace/ssh-directory /tekton/home/.ssh
[rsync-files : rsync] + chmod 700 /tekton/home/.ssh
[rsync-files : rsync] + chmod -R 400 /tekton/home/.ssh/id_rsa
[rsync-files : rsync] remote to local
[rsync-files : rsync] + '[' remote-to-local '=' remote-to-local ]
[rsync-files : rsync] + echo 'remote to local'
[rsync-files : rsync] + '[' true '=' true ]
[rsync-files : rsync] + rsync -ratlzv -e 'ssh -o StrictHostKeyChecking=no -i /tekton/home/.ssh/id_rsa' shaowenchen@chenshaowen.com:/Users/shaowenchen/Downloads/rsync/ .
[rsync-files : rsync] Warning: Permanently added 'chenshaowen.com,0.0.0.0' (ECDSA) to the list of known hosts.
[rsync-files : rsync] receiving file list ... done
[rsync-files : rsync] ./
[rsync-files : rsync] ISSUE_TEMPLATE.en.md
[rsync-files : rsync] PULL_REQUEST_TEMPLATE.en.md
[rsync-files : rsync]
[rsync-files : rsync] sent 186 bytes  received 1,125,429 bytes  750,410.00 bytes/sec
[rsync-files : rsync] total size is 1,130,767  speedup is 1.00

[verify : shell] /workspace/source
[verify : shell] total 1116
[verify : shell] drwxrwxrwx    3 501      dialout        199 Jun 18 02:49 .
[verify : shell] drwxrwxrwx    3 root     root            20 Jun 18 02:56 ..
[verify : shell] drwxr-xr-x    2 501      dialout         95 Jun 18 02:42 ISSUE_TEMPLATE.en.md
[verify : shell] -rw-r--r--    1 501      dialout        124 Jun 18 02:42 PULL_REQUEST_TEMPLATE.en.md
```
