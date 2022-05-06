# Anchore CLI

The Anchore CLI provides a command line interface on top of the Anchore Engine REST API.
Anchore CLI will try to connect to the Anchore Engine at http://localhost/v1 with no authentication. The username, password and URL for the server can be passed to the Anchore CLI as command line arguments

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/anchore-cli/0.2/anchore-cli.yaml
```

## Parameters

    - name: ARGS
      description: The Arguments to be passed to anchore command.
      type: array
    - name: ANCHORE_CLI_IMAGE
      default: anchore/engine-cli
      description: Anchore cli image to be used
    - name: ANCHORE_CLI_USER
      default: admin
      description: Anchore engine user name.      
    - name: ANCHORE_CLI_PASS
      default: foobar
      description: Anchore engine password.      
    - name: ANCHORE_CLI_URL
      default: http://192.168.0.101:8228/v1/
      description: Anchore engine URL.      
    - name: IMAGE_NAME
      default: openjdk:7-jre-alpine
      description: Image to be scanned


* **ARGS:** Arguments to be passed to anchore command

* **ANCHORE_CLI_IMAGE:** Anchore cli image to be used 

* **ANCHORE_CLI_USER:** Anchore cli user to be passed as secret variable

* **ANCHORE_CLI_PASS:** Arguments to be passed to anchore command

* **ANCHORE_CLI_URL:** Anchore Server URL

* **IMAGE_NAME:** Image to be scanned

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

## Usage

After creating the task, you should now be able to execute `anchore cli` commands by
specifying the command you would like to run as the `ARGS` or `SCRIPT` param.

The `ARGS` param takes an array of aws subcommands that will be executed as
part of this task and the `SCRIPT` param takes the multiple commands that you would like to run on aws CLI.


The `ConfigMap` and `Secret` give an example of how to define the Anchore server address and give credentials for logging in.

```YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: anchorecli-env-configmap
data:
  ANCHORE_SERVER: <Anchore server address>
---
apiVersion: v1
kind: Secret
metadata:
  name: anchorecli-env-secret
data:
  # choose one of username/password or auth token
  ANCHORE_USERNAME: <username>
  ANCHORE_PASSWORD: <password>
  
 Note: Anchore server should be installed as part of pre-requisite


