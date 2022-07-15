# Buildpacks

This pipeline builds source into a container image using [Cloud Native Buildpacks](https://buildpacks.io). To do that, it uses [builders](https://buildpacks.io/docs/concepts/components/builder/#what-is-a-builder) to run buildpacks against your application source.

> _**What are Cloud Native Buildpacks?**_
> 
> _Cloud Native Buildpacks are pluggable, modular tools that transform application source code into OCI images. They replace Dockerfiles in the app development lifecycle, and enable for swift rebasing of images and modular control over images (through the use of builders), among other benefits._

## Dependencies

- [`git-clone` task](https://github.com/tektoncd/catalog/tree/main/task/git-clone) 0.3 or newer
- [`buildpacks` task](https://github.com/tektoncd/catalog/tree/main/task/buildpacks/) 0.3 or newer
- [`buildpacks-phases` task](https://github.com/tektoncd/catalog/tree/main/task/buildpacks-phases/) 0.2 or newer

## Compatibility

- **Tekton** v0.17.0 and above
- **[Platform API][platform-api]** 0.4

[platform-api]: https://buildpacks.io/docs/reference/spec/platform-api/

## Install

#### Install dependencies (if missing)

```shell
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/git-clone/0.3/raw
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/buildpacks/0.3/raw
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/buildpacks-phases/0.2/raw
```

#### Install pipeline

```shell
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/pipeline/buildpacks/0.2/raw
```

## Workspaces

 - **`source-ws`**: Location where source is stored. _(REQUIRED)_
 - **`cache-ws`**: Location where cache is stored if CACHE_IMAGE is not provided. _(optional)_

## Parameters

 - **`BUILDER_IMAGE`**: The image on which builds will run (must include lifecycle and compatible buildpacks). _(REQUIRED)_
 - **`TRUST_BUILDER`**: Whether the builder image is trusted. When false, each build phase is executed in isolation and credentials are only shared with trusted images. _(optional, default: "false")_
 - **`APP_IMAGE`**: The name of where to store the app image. _(REQUIRED)_
 - **`SOURCE_URL`**: A git repo url where the source code resides. _(REQUIRED)_
 - **`SOURCE_REFERENCE`**: The branch, tag or SHA to checkout. _(optional, default: "")_
 - **`SOURCE_SUBPATH`**: A subpath within checked out source where the source to build is located. _(optional, default: "")_
 - **`ENV_VARS`**: Environment variables to set during _build-time_. _(optional, default: [""])_
 - **`PROCESS_TYPE`**: The default process type to set on the image. _(optional, default: "web")_
 - **`RUN_IMAGE`**: The name of the run image to use (defaults to image specified in builder). _(optional, default: "")_
 - **`CACHE_IMAGE`**: The name of the persistent cache image. _(optional, default: "")_
 - **`USER_ID`**: The user ID of the builder image user. _(optional, default: "1000")_
 - **`GROUP_ID`**: The group ID of the builder image user. _(optional, default: "1000")_

## Builders

_The following are the suggested [builders][builders] from the [Cloud Native Buildpacks][buildpacks-io] project. This is only a subset of builders available._

 - **`gcr.io/buildpacks/builder:v1`**: Ubuntu 18 base image with buildpacks for .NET, Go, Java, Node.js, and Python
 - **`heroku/buildpacks:18`**: Base builder for Heroku-18 stack, based on ubuntu:18.04 base image
 - **`heroku/buildpacks:20`**: Base builder for Heroku-20 stack, based on ubuntu:20.04 base image
 - **`paketobuildpacks/builder:base`**: Ubuntu bionic base image with buildpacks for Java, .NET Core, NodeJS, Go, Ruby, NGINX and Procfile
 - **`paketobuildpacks/builder:full`**: Ubuntu bionic base image with buildpacks for Java, .NET Core, NodeJS, Go, PHP, Ruby, Apache HTTPD, NGINX and Procfile
 - **`paketobuildpacks/builder:tiny`**: Tiny base image (bionic build image, distroless-like run image) with buildpacks for Java Native Image and Go

[builders]: (https://buildpacks.io/docs/concepts/components/builder/)
[buildpacks-io]: (https://buildpacks.io)

## Platforms

The Pipeline can be run on `linux/amd64` platform.

## Usage

See the following samples for usage:

 - **[`cache-image.yaml`](samples/cache-image.yaml)**: A PipelineRun configured to cache build artifacts in an image.
 - **[`cache-volume.yaml`](samples/cache-volume.yaml)**: A PipelineRun configured to cache build artifacts in a volume.
 - **[`env-vars.yaml`](samples/env-vars.yaml)**: A PipelineRun configured to provide _build-time_ environment variables.
 - **[`run-image.yaml`](samples/run-image.yaml)**: A PipelineRun configured to specify an explicit run image.

## Support

The [Buildpacks Community](http://buildpacks.io/community/) is always here to help. 

We can be found in our [discussion board][discussion-board] or [slack][slack] (`#tekton`).

[discussion-board]: https://github.com/buildpacks/community/discussions
[slack]: https://slack.buildpacks.io

## Contributing

We ❤ contributions.

This pipeline is maintained at [buildpacks/tekton-integration](https://github.com/buildpacks/tekton-integration). Issues, pull requests and other contributions can be made there. 

To learn more, read the [CONTRIBUTING][contributing] and [DEVELOPMENT][development] documents.

[contributing]: https://github.com/buildpacks/.github/blob/main/CONTRIBUTING.md
[development]: https://github.com/buildpacks/tekton-integration/blob/main/DEVELOPMENT.md
