# Remote SSH Commands

This task can be used to run shell commands on remote machine and produce the result. It is done by SSHing into the remote Host by providing the required credentials and the shell script which we want to run over there.

## Install the Task

```bash
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/remote-ssh-commands/0.1/raw
```

## Parameters

- **HOST**: The server host to which you want to connect. (**Required**)
- **USERNAME**: Connect as an user. (**Required**)
- **PORT**: Port number to connect (_default:_ 22).
- **SSH_SCRIPT**: The shell script which you want to run on remote host. (**Required**)
- **USE_INSECURE_CIPHER**: Boolean value to include ciphers or not. (_default_:"false")

## Workspaces

- **credentials**: The workspace contains secrets can be used to authenticate with the HOST.
  ### Secrets
  - **privatekey**: The private SSH key in case public SSH key is present on host.
  - **passphrase**: The passphrase used at the time of generating the private key for encryption.
  - **password**: User password to connect to host.
  - **fingerprint**: Fingerprint SHA256 of the host public key, default is to skip verification.
  - **ciphers**: The allowed cipher algorithms. If unspecified then a sensible.

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

1. Create the `Secret` by putting in the required values

```yaml
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: remote-ssh-secret
data:
  passphrase: passphrase
  privatekey: privatekey
```

2. Create the `TaskRun`

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: remote-ssh-commands-run
spec:
  taskRef:
    name: remote-ssh-commands
  workspaces:
    - name: credentials
      secret:
        secretName: remote-ssh-secret
  params:
    - name: HOST
      value: "127.0.0.1"
    - name: USERNAME
      value: "username"
    - name: SSH_SCRIPT
      value: |
        #!/bin/sh
        hostname
        echo "--------"
        pwd
        ls -a
```

### Output

```bash
$ tkn t logs -f
? Select task: remote-ssh-commands
[ssh] + export 'script=#!/bin/sh
[ssh] hostname
[ssh] echo --------
[ssh] pwd
[ssh] ls -a
[ssh] '
[ssh] + cmd=
[ssh] + '[[' -f ./privatekey ]]
[ssh] + cmd=' -i ./privatekey'
[ssh] + '[[' -f ./password ]]
[ssh] + '[[' -f ./passphrase ]]
[ssh] + cat ./passphrase
[ssh] + cmd=' -i ./privatekey --ssh-passphrase XXXXXX'
[ssh] + '[[' -f ./fingerprint ]]
[ssh] + '[[' -f ./ciphers ]]
[ssh] + '[[' false '==' true ]]
[ssh] + drone-ssh -H 127.0.0.1 -p 22 -u username -s '#!/bin/sh
[ssh] hostname
[ssh] echo --------
[ssh] pwd
[ssh] ls -a
[ssh] ' -i ./privatekey --ssh-passphrase 'XXXXX'
[ssh] ======CMD======
[ssh] #!/bin/sh
[ssh] hostname
[ssh] echo --------
[ssh] pwd
[ssh] ls -a
[ssh]
[ssh] ======END======
[ssh] out: ssh-test
[ssh] out: --------
[ssh] out: /home/username
[ssh] out: .
[ssh] out: ..
[ssh] out: .bash_history
[ssh] out: .bash_logout
[ssh] out: .bashrc
[ssh] out: .gnupg
[ssh] out: .profile
[ssh] out: .ssh
[ssh] out: desktop
[ssh] ==============================================
[ssh] ✅ Successfully executed commands to all host.
[ssh] ==============================================
```
