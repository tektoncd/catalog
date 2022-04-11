# s2i Angular Nginx

This task build an Angular application avoiding the use of customized s2i builder images. This task use official Red Hat images (like Nodejs and Nginx) to package the entire application into a single lightweight docker image ready for production.

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/s2i-angular-nginx/0.1/s2i-angular-nginx.yaml
```

## Parameters

* **NODEJS_VERSION:** the version of NodeJs used to install dependencies and build the Angular application

* **CONTEXT_PATH:** the directory in the source repository where source should be found (default: . )

* **TLSVERIFY:** this flags is needed to verify (or not) the TLS of the registry to push the resulting image

* **IMAGE:** the URL of the resulting image

* **BUILDER_IMAGE:** the buildah image needed to build the resulting image

## Results
* **IMAGE_DIGEST:** digest of the image just built.

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage

This snippet of `Pipeline` implements the typical `build` step for a standard Angular application. The task understand that the source code of the application is served through the workspace `source`.

```YAML
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: myapp-ci-pipeline
spec:
  tasks:
    - name: checkout
      taskRef:
        name: git-clone # checkout the source code of the application
    - name: build
      taskRef:
        name: s2i-angular-nginx
      params:
        - name: NODEJS_VERSION
          value: '16'
        - name: CONTEXT_PATH
          value: '.'
        - name: TLSVERIFY
          value: 'false'
        - name: IMAGE
          value: docker.io/my_user/myapp:latest
      workspaces:
        - name: source
          workspace: source-code
```
