# OpenWhisk NodeJS Runtime for Knative

This directory is used to build and test the OpenWhisk NodeJS runtime for Knative.

## Pre-requisites

Complete the pre-requisites and Tekton/Knative installation and configuration by following instructions in the top-level [README](../../README.md) from this repository.

### Verify your Kubernetes, Tekton, & Knative pods are running

Verify **kube-system**, **istio-system**, **tekton-pipelines**, and **knative-xxx** pods are all **Running**
```
$ kubectl get pods --all-namespaces
```
<details>
    <summary>Sample output</summary>

```
$ kubectl get pods --all-namespaces
NAMESPACE          NAME                                            READY   STATUS      RESTARTS   AGE
istio-system       cluster-local-gateway-547467ccf6-p8n72          1/1     Running     1          8d
istio-system       istio-citadel-7d64db8bcf-m7gsj                  1/1     Running     0          8d
istio-system       istio-cleanup-secrets-8lzj4                     0/1     Completed   0          8d
istio-system       istio-egressgateway-6ddf4c8bd6-2dxhc            1/1     Running     1          8d
istio-system       istio-galley-7dd996474-pdd6h                    1/1     Running     1          8d
istio-system       istio-ingressgateway-84b89d647f-cxrwx           1/1     Running     1          8d
istio-system       istio-pilot-86bb4fcbbd-5ns5q                    2/2     Running     0          8d
istio-system       istio-pilot-86bb4fcbbd-vd2xr                    2/2     Running     0          8d
istio-system       istio-pilot-86bb4fcbbd-zstrw                    2/2     Running     0          8d
istio-system       istio-policy-5c4d9ff96b-559db                   2/2     Running     1          8d
istio-system       istio-sidecar-injector-6977b5cf5b-94hj5         1/1     Running     0          8d
istio-system       istio-statsd-prom-bridge-b44b96d7b-kzkzc        1/1     Running     0          8d
istio-system       istio-telemetry-7676df547f-jp952                2/2     Running     1          8d
istio-system       knative-ingressgateway-75644679c7-c2kxj         1/1     Running     1          8d
knative-build      build-controller-658d64d9bd-6qp2c               1/1     Running     0          8d
knative-build      build-webhook-6bb747665f-v8nk2                  1/1     Running     1          8d
knative-eventing   eventing-controller-cfbb757bd-czx99             1/1     Running     0          8d
knative-eventing   in-memory-channel-controller-75d6cc4b77-6c8st   1/1     Running     1          8d
knative-eventing   in-memory-channel-dispatcher-c89db8bb8-phlxw    2/2     Running     7          8d
knative-eventing   webhook-5fbb8dbcc7-nhwp5                        1/1     Running     0          8d
knative-serving    activator-69b8474d6b-58hh2                      2/2     Running     1          8d
knative-serving    autoscaler-6579b57774-cvvzj                     2/2     Running     1          8d
knative-serving    controller-66cd7d99df-hgswh                     1/1     Running     0          8d
knative-serving    webhook-6d9568d-czt8m                           1/1     Running     0          8d
knative-sources    controller-manager-0                            1/1     Running     1          8d
kube-system        coredns-86c58d9df4-ms8qs                        1/1     Running     0          8d
kube-system        coredns-86c58d9df4-x29vt                        1/1     Running     0          8d
kube-system        etcd-docker-desktop                             1/1     Running     3          8d
kube-system        kube-apiserver-docker-desktop                   1/1     Running     3          8d
kube-system        kube-controller-manager-docker-desktop          1/1     Running     5          8d
kube-system        kube-proxy-mltsm                                1/1     Running     0          8d
kube-system        kube-scheduler-docker-desktop                   1/1     Running     5          8d
tekton-pipelines   tekton-pipelines-controller-b64b4788d-89rxg     1/1     Running     0          8d
tekton-pipelines   tekton-pipelines-webhook-6cc96c4b7c-znrmb       1/1     Running     0          8d
```
</details>

## Example 1: Hello World OpenWhisk Action

We have included various different test cases but will start with the simple "helloworld" test case to demonstrate how to use Tekton to build your function into container image and then deploy it as a Knative Service.

### Build HelloWorld

#### Configure taskrun.yaml

OpenWhisk Task requires Git resource representing OpenWhisk Runtime GitHub repository as an input. The Tekton Pipeline clones runtime repository and allows the task to build OpenWhisk runtime along with action code. OpenWhisk Task also requires Image resource representing OpenWhisk Runtime image as an output to build an image and push it to any registry.

To do this,
- Copy [taskrun.yaml.tmpl](examples/01-helloworld/taskrun-helloworld.yaml.tmpl) to `taskrun.yaml`.
- Replace ```${DOCKER_USERNAME}``` with your own Docker username in `taskrun.yaml`.

If you wish to run repeated tests you MAY set an environment variable and use ```sed``` to replace the ```${DOCKER_USERNAME}``` within any of the test's Kubernetes Build YAML files as follows:

```
# If you have not already exported your Dockerhub username, use the following command:
export DOCKER_USERNAME="myusername"

# Generate the build file from the template using your Dockerhub username set in the environment
sed 's/${DOCKER_USERNAME}/'"$DOCKER_USERNAME"'/' taskrun.yaml.tmpl > taskrun.yaml
```

<details>
    <summary>taskrun.yaml.tmpl contents</summary>

```
# Git Pipeline Resource for OpenWhisk NodeJS Runtime
apiVersion: tekton.dev/v1alpha1
kind: PipelineResource
metadata:
    name: openwhisk-nodejs-runtime-git
spec:
    type: git
    params:
        - name: revision
          value: master
        - name: url
          value: https://github.com/apache/openwhisk-runtime-nodejs.git
---

# Image Pipeline Resource for OpenWhisk NodeJS Sample Application
apiVersion: tekton.dev/v1alpha1
kind: PipelineResource
metadata:
    name: openwhisk-nodejs-helloworld-image
spec:
    type: image
    params:
        - name: url
          value: docker.io/${DOCKER_USERNAME}/openwhisk-nodejs-helloworld
---

# Task Run to build NodeJS image with the action source
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
    name: openwhisk-nodejs-helloworld
spec:
    serviceAccountName: openwhisk-runtime-builder
    taskRef:
        name: task-openwhisk
    trigger:
        type: manual
    resources:
        inputs:
            - name: runtime-git
              resourceRef:
                name: openwhisk-nodejs-runtime-git
        outputs:
            - name: runtime-image
                  resourceRef:
                    name: openwhisk-nodejs-helloworld-image
    params:
        - name: DOCKERFILE
          value: "./runtime-git/core/nodejs10Action/knative/Dockerfile"
        - name: OW_ACTION_NAME
          value: "nodejs-helloworld"
        - name: OW_ACTION_CODE
          value: "function main() {return {payload: 'Hello World!'};}"
        - name: OW_PROJECT_URL
          value: ""
---
```
</details>

OpenWhisk Task defines a set of parameters needed while building the OpenWhisk NodeJS runtime. You can refer to OpenWhisk publication [How to Run OpenWhisk Actions on Knative?](https://medium.com/openwhisk/how-to-run-openwhisk-actions-on-knative-95fcaf655a9e) to know more about these parameters.


```bash
kubectl apply -f taskrun.yaml
pipelineresource.tekton.dev/openwhisk-nodejs-runtime-git unchanged
pipelineresource.tekton.dev/openwhisk-nodejs-helloworld-image unchanged
taskrun.tekton.dev/openwhisk-nodejs-helloworld created
```

This creates a pod with a NodeJS runtime and all the action metadata (action code, main function name, etc) integrated into the container image.

```bash
kubectl get taskrun
NAME                          SUCCEEDED   REASON        STARTTIME   COMPLETIONTIME
openwhisk-nodejs-helloworld   True        Succeeded     28m         26m
```

#### Troubleshooting the build

If for any reason there is a failure creating the pod, we can troubleshoot the deployment with:

#### `kubectl get pods`

```
kubectl get pod openwhisk-nodejs-helloworld-pod-442e21 -o yaml
```

Which lists the containers and their status under `ContainerStatuses`:

- step-credential-initializer-75hkz
- step-git-source-openwhisk-nodejs-runtime-git-cvdjj
- step-add-ow-env-to-dockerfile
- step-build-openwhisk-nodejs-runtime
- step-image-digest-exporter-add-ow-env-to-dockerfile-9dlnr
- step-image-digest-exporter-build-openwhisk-nodejs-runtime-7mllr
- step-image-digest-exporter-update-dockerfile-for-tekton-tgfj8
- step-update-dockerfile-for-tekton
- create-dir-default-image-output-qkcmn
- step-place-tools

#### `kubectl logs`

Now, the logs of each of these task steps (containers) can be retrieved using:

```
kubectl logs <pod-name> -c <container-name>
```

For example:

```
kubectl logs openwhisk-nodejs-helloworld-pod-442e21 -c step-build-openwhisk-nodejs-runtime
INFO[0007] Downloading base image node:10.15.0-stretch
error building image: getting stage builder for stage 0: Get https://index.docker.io/v2/: net/http: TLS handshake timeout
```

### Create HelloWorld Knative Service

Now that you have built the OpenWhisk NodeJS runtime image with the `helloworld` function "baked" into it, you can can deploy the image as a Knative Service.

#### Using Knative CLI ```kn```

```kn``` is the Knative CLI which can be used to create a service using the NodeJS image created using ```taskrun.yaml```.

```bash
kn service create nodejs-helloworld --image docker.io/${DOCKER_USERNAME}/openwhisk-nodejs-helloworld
Service 'nodejs-helloworld' successfully created in namespace 'default'.
Waiting for service 'nodejs-helloworld' to become ready ... OK

Service URL:
http://nodejs-helloworld.default.example.com
```

#### Using Knative Service YAML

You will need to configure the Service template to point to the Docker Hub repo. where your Knative OpenWhisk runtime (with the Hello World function) will be "pulled" from.

To do this,
- Copy [service.yaml.tmpl](examples/01-helloworld/service-helloworld.yaml.tmpl) to `service.yaml`.
- Replace ```${DOCKER_USERNAME}``` with your own Docker username in `service.yaml`.

As described for 'taskrun.yaml.tmpl', you MAY set an environment variable and use ```sed``` to replace the ```${DOCKER_USERNAME}``` within any of the test's Kubernetes Build YAML files as follows:

```
export DOCKER_USERNAME="myusername"
sed 's/${DOCKER_USERNAME}/'"$DOCKER_USERNAME"'/' service.yaml.tmpl > service.yaml
```

<details>
    <summary>service.yaml.tmpl contents</summary>

```
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: nodejs-helloworld
  namespace: default
spec:
  runLatest:
    configuration:
      revisionTemplate:
        spec:
          container:
            image: docker.io/${DOCKER_USERNAME}/openwhisk-nodejs-helloworld
```
</details>

```bash
kubectl apply -f service.yaml
service.serving.knative.dev/nodejs-helloworld created
```

### Run HelloWorld

```bash
curl -H "Host: nodejs-helloworld.default.example.com" -X POST http://${IP_ADDRESS}
{"OK":true}
curl -H "Host: nodejs-helloworld.default.example.com" -X POST http://${IP_ADDRESS}
{"payload":"Hello World!"}
```

## Example 2: Actions with JSON in / JSON out Interface

### Build HelloWorld with JSON Payload as Parameters
#### Configure taskrun.yaml

Now, let's update the OpenWhisk Task parameter ```OW_ACTION_CODE``` to ```function main(params) {return {payload: 'Hello ' + params.name + ' from ' + params.place + '!'};}```

<details>
    <summary>taskrun.yaml.tmpl contents</summary>

```
# Git Pipeline Resource for OpenWhisk NodeJS Runtime
apiVersion: tekton.dev/v1alpha1
kind: PipelineResource
metadata:
    name: openwhisk-nodejs-runtime-git
spec:
    type: git
    params:
        - name: revision
          value: master
        - name: url
          value: https://github.com/apache/openwhisk-runtime-nodejs.git
---

# Image Pipeline Resource for OpenWhisk NodeJS Sample Application
apiVersion: tekton.dev/v1alpha1
kind: PipelineResource
metadata:
    name: openwhisk-nodejs-helloworld-with-params-image
spec:
    type: image
    params:
        - name: url
          value: docker.io/${DOCKER_USERNAME}/openwhisk-nodejs-helloworld-with-params
---

# Task Run to build NodeJS image with the action source
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
    name: openwhisk-nodejs-helloworld-with-params
spec:
    serviceAccountName: openwhisk-runtime-builder
    taskRef:
        name: task-openwhisk
    trigger:
        type: manual
    resources:
        inputs:
            - name: runtime-git
              resourceRef:
                name: openwhisk-nodejs-runtime-git
        outputs:
            - name: runtime-image
                  resourceRef:
                    name: openwhisk-nodejs-helloworld-with-params-image
    params:
        - name: DOCKERFILE
          value: "./runtime-git/core/nodejs10Action/knative/Dockerfile"
        - name: OW_ACTION_NAME
          value: "nodejs-helloworld"
        - name: OW_ACTION_CODE
          value: "function main(params) {return {payload: 'Hello ' + params.name + ' from ' + params.place + '!'};}"
        - name: OW_PROJECT_URL
          value: ""
---
```
</details>

```bash
kubectl apply -f taskrun.yaml
pipelineresource.tekton.dev/openwhisk-nodejs-runtime-git unchanged
pipelineresource.tekton.dev/openwhisk-nodejs-helloworld-with-params-image created
taskrun.tekton.dev/openwhisk-nodejs-helloworld-with-params created
```

### Create HelloWorld Knative Service

```bash
kn service create nodejs-helloworld-with-params --image docker.io/${DOCKER_USERNAME}/openwhisk-nodejs-helloworld-with-params
Service 'nodejs-helloworld-with-params' successfully created in namespace 'default'.
Waiting for service 'nodejs-helloworld-with-params' to become ready ... OK

Service URL:
http://nodejs-helloworld-with-params.default.example.com
```

### Run HelloWorld

```bash
curl -H "Host: nodejs-helloworld-with-params.default.example.com" -H "Content-Type: application/json" -d '{"value":{"name": "Jill", "place": "OK"}}' http://${IP_ADDRESS}
{"payload":"Hello Jill from OK!"}

curl -H "Host: nodejs-helloworld-with-params.default.example.com" -H "Content-Type: application/json" -d '{"value":{"name": "Bob", "place": "NY"}}' http://${IP_ADDRESS}
{"payload":"Hello Bob from NY!"}
```

## Example 3: OpenWhisk Action File from GitHub Repo

### Pull and build OpenWhisk Action from GitHub

#### Configure taskrun.yaml

Now, let's update the OpenWhisk Task parameter ```OW_PROJECT_URL``` to ```https://raw.githubusercontent.com/tektoncd/catalog/openwhisk/openwhisk/runtimes/javascript/examples/03-github/hello.js```

<details>
    <summary>taskrun.yaml.tmpl contents</summary>

```
# Git Pipeline Resource for OpenWhisk NodeJS Runtime
apiVersion: tekton.dev/v1alpha1
kind: PipelineResource
metadata:
    name: openwhisk-nodejs-runtime-git
spec:
    type: git
    params:
        - name: revision
          value: master
        - name: url
          value: https://github.com/apache/openwhisk-runtime-nodejs.git
---

# Image Pipeline Resource for OpenWhisk NodeJS Sample Application
apiVersion: tekton.dev/v1alpha1
kind: PipelineResource
metadata:
    name: openwhisk-nodejs-raw-github-image
spec:
    type: image
    params:
        - name: url
          value: docker.io/${DOCKER_USERNAME}/openwhisk-nodejs-raw-github
---

# Task Run to build NodeJS image with the action source
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
    name: openwhisk-nodejs-raw-github
spec:
    serviceAccountName: openwhisk-runtime-builder
    taskRef:
        name: openwhisk
    trigger:
        type: manual
    resources:
        inputs:
            - name: runtime-git
              resourceRef:
                name: openwhisk-nodejs-runtime-git
        outputs:
            - name: runtime-image
              resourceRef:
                name: openwhisk-nodejs-raw-github-image
    params:
        - name: DOCKERFILE
          value: "./runtime-git/core/nodejs10Action/knative/Dockerfile"
        - name: OW_ACTION_NAME
          value: "nodejs-helloworld"
        - name: OW_ACTION_CODE
          value: ""
        - name: OW_PROJECT_URL
          value: "https://raw.githubusercontent.com/tektoncd/catalog/openwhisk/openwhisk/runtimes/javascript/examples/03-github/hello.js"
---
```
</details>

```bash
kubectl apply -f taskrun.yaml
pipelineresource.tekton.dev/openwhisk-nodejs-runtime-git unchanged
pipelineresource.tekton.dev/openwhisk-nodejs-raw-github-image created
taskrun.tekton.dev/openwhisk-nodejs-raw-github created
```

### Create Knative Service

```bash
kn service create nodejs-raw-github --image docker.io/${DOCKER_USERNAME}/openwhisk-nodejs-raw-github
Service 'nodejs-raw-github' successfully created in namespace 'default'.
Waiting for service 'nodejs-raw-github' to become ready ... OK

Service URL:
http://nodejs-raw-github.default.example.com
```

### Access Knative Service

```bash
curl -H "Host: nodejs-raw-github.default.example.com" -X POST http://${IP_ADDRESS}
{"payload":"Hello World!"}
```

> Note: There is a limitation to what kind of action code you can pull from GitHub in which single line or multiline comments are not permitted. The way OpenWhisk Task pulls the file and the action source is assigned to NodeJS runtime variable `OW_ACTION_CODE` misbehaves if the code has comments, for example, when an action code has a single line comment starting with ```//```, the OpenWhisk Task Run fails and complains:

```
error building image: parsing dockerfile: Dockerfile parse error line 43: unknown instruction: //
```

## Example 4: OpenWhisk Action from Zip File

### Pull zip Action file from GitHub and build image

#### Configure taskrun.yaml

Now, let's update the OpenWhisk Task parameter ```OW_PROJECT_URL``` to ```https://github.com/tektoncd/catalog/raw/main/openwhisk/runtimes/javascript/examples/04-zip/action.zip```

<details>
    <summary>taskrun.yaml.tmpl contents</summary>

```
# Git Pipeline Resource for OpenWhisk NodeJS Runtime
apiVersion: tekton.dev/v1alpha1
kind: PipelineResource
metadata:
    name: openwhisk-nodejs-runtime-git
spec:
    type: git
    params:
        - name: revision
          value: master
        - name: url
          value: https://github.com/apache/openwhisk-runtime-nodejs.git
---

# Image Pipeline Resource for OpenWhisk NodeJS Sample Application
apiVersion: tekton.dev/v1alpha1
kind: PipelineResource
metadata:
    name: openwhisk-nodejs-zip-image
spec:
    type: image
    params:
        - name: url
          value: docker.io/${DOCKER_USERNAME}/openwhisk-nodejs-zip
---

# Task Run to build NodeJS image with the action source
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
    name: openwhisk-nodejs-zip
spec:
    serviceAccountName: openwhisk-runtime-builder
    taskRef:
        name: openwhisk
    trigger:
        type: manual
    resources:
        inputs:
            - name: runtime-git
              resourceRef:
                name: openwhisk-nodejs-runtime-git
        outputs:
            - name: runtime-image
              resourceRef:
                name: openwhisk-nodejs-zip-image
    params:
        - name: DOCKERFILE
          value: "./runtime-git/core/nodejs10Action/knative/Dockerfile"
        - name: OW_ACTION_NAME
          value: "nodejs-helloworld"
        - name: OW_ACTION_CODE
          value: ""
        - name: OW_PROJECT_URL
          value: "https://github.com/tektoncd/catalog/raw/main/openwhisk/runtimes/javascript/examples/04-zip/action.zip"
---
```
</details>

```bash
kubectl apply -f taskrun.yaml
pipelineresource.tekton.dev/openwhisk-nodejs-runtime-git unchanged
pipelineresource.tekton.dev/openwhisk-nodejs-zip-image created
taskrun.tekton.dev/openwhisk-nodejs-zip created
```

### Create Knative Service

```bash
kn service create nodejs-zip --image docker.io/${DOCKER_USERNAME}/openwhisk-nodejs-zip
Service 'nodejs-zip' successfully created in namespace 'default'.
Waiting for service 'nodejs-zip' to become ready ... OK

Service URL:
http://nodejs-zip.default.example.com
```

### Access Knative Service

```bash
curl -H "Host: nodejs-zip.default.example.com" -X POST http://${IP_ADDRESS}
{"OK":true}

curl -H "Host: nodejs-zip.default.example.com" -X POST http://${IP_ADDRESS}
{"payload":"Hello, stranger from somewhere!"}

curl -H "Host: nodejs-zip.default.example.com" -H "Content-Type: application/json" -d '{"value":{"name": "Bob", "place": "NY"}}' http://${IP_ADDRESS}
{"payload":"Hello, Bob from NY!"}
```
