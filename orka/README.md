# Orka

This `Task` runs a script on a Mac VM using MacStadium's Orka service.

Orka provides an API for managing Mac VMs across physical Mac hardware, hosted
by MacStadium.
This `Task` requires you to already have Orka setup and a user account with a token
configured.
This `Task` also requires that you configure the VPN from your cloud environment to
Orka, as specified [here](https://orkadocs.macstadium.com/docs/prerequisites#section-set-up-vpn).

The `Dockerfile` used to build the container in the `Task` is also contained in this directory.
An image is currently available at `gcr.io/dlorenc-vmtest2/orka`.

It works by:
* creating a VM
* copying the Tekton workspace over to it
* running the specified script
* copying the Tekton workspace back

This is mainly a proof-of-concept today.

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/orka/orka.yaml
```

## Inputs

### Parameters

* **API_URL**: The URL to access the Orka API. Usually http://10.221.188.100.

* **SCRIPT**: The contents of the script to run on the created VM.

### Resources

This task does not use any resources today.

## Outputs

This task does not produce any outputs today.

## Usage

This TaskRun runs the Task with a script to check the OS and XCode versions.

```
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  name: example-run
spec:
  taskRef:
    name: orka-script
  inputs:
    params:
    - name: script
      value: |
        #!/bin/bash
        uname -a
        xcode-select -v
```
