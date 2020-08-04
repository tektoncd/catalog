# S2i Java Binary Build

Sometimes, we won't be able to use the source to image approach,
because we previously generated the binary using a build automation service.
In this situation, we can still use the builder images for runtime.

[S2i Java Binary Build](./s2i-java-binary-build.yaml) task takes `binary` file as an input and create an
`image` of that application and pass the image URL to the `result` of the task.

### **PRE-REQUISITE**: This task requires an openshift cluster to run.

## Installing the Task

```bash
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/task/s2i-java-binary-build/0.1/s2i-java-binary-build.yaml
```

## Installing the ClusterRoleBinding

```bash
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/task/s2i-java-binary-build/0.1/support/clusterrolebinding.yaml
```

## Parameters

- **BUILD_NAME**: The Name to use for generated build artifacts. (_default_:`java-binary-build`)
- **BINARY_PATH**: The Path to the directory where binary is present.

## Workspaces

- **binary**: Workspace containing the binary from which image needs to be generated.

## Results

- **image-url**: Generated image URL, that can be used by the other tasks. 

## Usage

This task creates a build configuration and starts a new build from the 
created BuildConfig.
`Workspace` containing binary file should be present, so that task can build
image from the existing binary.
As this task is very specific to `openshift`, hence we need to install 
`ClusterRoleBinding` so that we can get required dependency from openshift.
Once image is build this task outputs the `image URL` in the form of `results`
so that it can be used in the other tasks in the pipeline.

An example of this is shown in the test [pipeline](./tests/run.yaml), where binary is build using [maven](https://github.com/tektoncd/catalog/tree/master/task/maven/0.1) task
and once the binary is build we can use the generated binary in this task to create
an image and at last when image is built we can `copy` the image to required destination
image registry using [skopeo](https://github.com/tektoncd/catalog/tree/master/task/skopeo-copy/0.1) task.
