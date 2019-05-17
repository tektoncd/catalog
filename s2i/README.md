# S2I

This Task builds source into a container image using Project Atomic's
[source-to-image/s2i](https://github.com/openshift/source-to-image). 

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/s2i/s2i-nodejs.yaml
```

## Inputs

### Parameters

* **BUILDER_IMAGE**: The name of the image containing the s2i command. See
  note below.  (_default:_ quay.io/openshift-pipeline/s2i)
* **S2I_IMAGE**: S2I image needed for specific framework
* **PATH_CONTEXT**: Source path from where s2i command need to be run.


### Resources

* **git-source**: A `git`-type `PipelineResource` specifying the location of the
  source to build.

## Outputs

### Resources

* **image**: An `image`-type `PipelineResource` specify the image that should
  be built.

## Usage

[Example](./examples) directory contains examples of taskrun in action using this s2i task.
