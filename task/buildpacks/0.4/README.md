# Buildpacks

This task builds source into a container image using [Cloud Native Buildpacks](https://buildpacks.io). To do that, it uses [builders](https://buildpacks.io/docs/concepts/components/builder/#what-is-a-builder) to run buildpacks against your application source.

> _**What are Cloud Native Buildpacks?**_
> 
> _Cloud Native Buildpacks are pluggable, modular tools that transform application source code into OCI images. They replace Dockerfiles in the app development lifecycle, and enable for swift rebasing of images and modular control over images (through the use of builders), among other benefits._

See also [`buildpacks-phases`](../../buildpacks-phases) for the deconstructed version of this task, which runs each of the [lifecycle phases](https://buildpacks.io/docs/concepts/components/lifecycle/#phases) individually. This task uses the [creator binary](https://github.com/buildpacks/spec/blob/platform/0.4/platform.md#operations), which coordinates and runs all of the phases.

## Compatibility

- **Tekton** v0.17.0 and above
- **[Platform API][platform-api]** 0.4
    - For other versions, see [previous versions](#previous-versions).

## Install

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/task/buildpacks/0.4/buildpacks.yaml
```

## Workspaces

 - **`source`**: Directory where application source is located. _(REQUIRED)_
 - **`cache`**: Directory where cache is stored (when no cache image is provided). _(optional)_
 - **`dockerconfig`**: An [optional workspace](https://github.com/tektoncd/pipeline/blob/main/docs/workspaces.md#using-workspaces-in-tasks)
  that allows providing a `.docker/config.json` file for Builpacks lifecycle binary to access the container registry. The file should be placed at
  the root of the Workspace with name `config.json`. _(optional)_


## Parameters

 - **`APP_IMAGE`**: The name of where to store the app image. _(REQUIRED)_
 - **`BUILDER_IMAGE`**: The image on which builds will run (must include lifecycle and compatible buildpacks). _(REQUIRED)_
 - **`SOURCE_SUBPATH`**: A subpath within the `source` input where the source to build is located. _(optional, default: "")_
 - **`ENV_VARS`**: Environment variables to set during _build-time_. _(optional, default: [])_
 - **`PROCESS_TYPE`**: The default process type to set on the image. _(optional, default: "web")_
 - **`RUN_IMAGE`**: Reference to a run image to use. _(optional, default: "")_
 - **`CACHE_IMAGE`**: The name of the persistent app cache image (if no cache workspace is provided). _(optional, default: "")_
 - **`SKIP_RESTORE`**: Do not write layer metadata or restore cached layers. _(optional, default: "false")_
 - **`USER_ID`**: The user ID of the builder image user. _(optional, default: "1000")_
 - **`GROUP_ID`**: The group ID of the builder image user. _(optional, default: "1000")_
 - **`PLATFORM_DIR`**: The name of the platform directory. _(optional, default: "empty-dir")_

## Results

 - **`APP_IMAGE_DIGEST`**: The digest of the built `APP_IMAGE`.

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

The Task can be run on `linux/amd64` platform.

## Usage

See the following samples for usage:

 - **[`env-vars.yaml`](samples/env-vars.yaml)**: A PipelineRun configured to provide _build-time_ environment variables.
 - **[`results.yaml`](samples/results.yaml)**: A PipelineRun configured to demonstrate usage of task results.
 - **[`dockerconfig.yaml`](samples/dockerconfig.yaml)**: A PipelineRun configured to demonstrate usage of `dockerconfig` workspace for referencing `.docker/config.json` file.

## Support

The [Buildpacks Community](http://buildpacks.io/community/) is always here to help. 

We can be found in our [discussion board][discussion-board] or [slack][slack] (`#tekton`).

[discussion-board]: https://github.com/buildpacks/community/discussions
[slack]: https://slack.buildpacks.io

## Contributing

We ❤ contributions.

This task is maintained at [buildpacks/tekton-integration](https://github.com/buildpacks/tekton-integration). Issues, pull requests and other contributions can be made there. 

To learn more, read the [CONTRIBUTING][contributing] and [DEVELOPMENT][development] documents.

[contributing]: https://github.com/buildpacks/.github/blob/main/CONTRIBUTING.md
[development]: https://github.com/buildpacks/tekton-integration/blob/main/DEVELOPMENT.md

## Previous Versions

For support of previous [Platform API][platform-api]s use a previous version of this task.

> Be sure to also supply a compatible builder image (`BUILDER_IMAGE` input) when running the task (i.e. one that has a lifecycle that supports the platform API).

| Version        | Platform API
|----            |-----
| [0.2](../0.2/) | [0.3][platform-api-0.3]

[platform-api]: https://buildpacks.io/docs/reference/spec/platform-api/
[platform-api-0.3]: https://github.com/buildpacks/spec/blob/platform/0.3/platform.md
