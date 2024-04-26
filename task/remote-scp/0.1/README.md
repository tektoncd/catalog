# Remote SCP
Remote SCP is a simple tool to copy files from a remote local machine to your server.

## Install the Task
```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/remote-scp/0.1/raw
```
## Parameters
HOST: The server host to which you want to connect. (Required)
USERNAME: Connect as an user. (Required)
PORT: Port number to connect (default: 22).
TO_PATH: The path to which you want to copy the file. (Required)
LOCAL_PATH: The path of the file to be copied. (Required)

## Workspaces
- credentials: The workspace contains secrets can be used to authenticate with the HOST.
    Secrets
    id_rsa: The private key of the user.
- storage: The workspace contains the file to be copied.
    PersistentVolumeClaim
## Platforms
The Task can be run on linux/amd64 platform.
## Usage
1. Create the Secret by putting in the required values
```yaml
---
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: remote-scp-secret
data:
  id_rsa: |
    <base64 encoded private key>
```
2. Create the PVC
```yaml
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: test-pv
spec:
  storageClassName: manual
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  nfs:
    path: /nfs/path/
    server: 127.0.0.1
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 2Gi
```
3. Create Test File 
```bash
touch /nfs/path/test.txt
```
4. Create the TaskRun
```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: remote-scp-run
spec:
  taskRef:
    name: remote-scp
  workspaces:
    - name: credentials
      secret:
        secretName: remote-scp-secret
    - name: storage
      persistentVolumeClaim:
        claimName: test-pvc
  params:
    - name: HOST
      value: "server.boychai.xyz"
    - name: PORT
      value: "45"
    - name: USERNAME
      value: "root"
    - name: TO_PATH
      value: "/temp/"
    - name: LOCAL_PATH
      value: "test.txt"
```

## Output
```text
drone-scp version: v1.6.14
tar all files into /tmp/OUGGuOpyIt.tar.gz
remote server os type is unix
scp file to server.
create folder /temp/
remove file OUGGuOpyIt.tar.gz
untar file OUGGuOpyIt.tar.gz
===================================================
✅ Successfully executed transfer data to all host
===================================================
```