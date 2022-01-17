# Contributing to the catalog repo

Thank you for your interest in contributing!

This doc is about how to contribute to this repo specifically. For how to
contribute to tektoncd projects in general, see [the overview in our README](README.md)
and the individual `CONTRIBUTING.md` files in each respective project.

**All contributors must comply with
[the code of conduct](./code-of-conduct.md).**

PRs are welcome, and will follow
[the tektoncd pull request process](https://github.com/tektoncd/community/blob/main/process.md#pull-request-process).

## How to Contribute a Task or Pipeline

The Catalog repository is intended to serve as a location where users can find
`Task`s and `Pipeline`s that are maintained, useful and follow established
best practices.

The process for contributing looks like this:

1. Fork this repository, develop and test your `Task`s.
2. Create a new folder for your `Task`(s)
3. Ensure your Task
   1. Follows the [guidelines](#guidelines)
   2. Meets the [technical requirements](#technical-requirements)
   3. Includes [OWNERS](#owning-and-maintaining-a-task)
4. Submit a pull request.

### Guidelines

When reviewing PRs that add new `Task`s or `Pipeline`s, maintainers will follow
the following guidelines:

* Submissions should be useful in real-world applications.
While this repository is meant to be educational, its primary goal is to serve
as a place users can find, share and discover useful components.
This is **not** a samples repo to showcase Tekton features, this is a collection
* Submissions should follow established [authoring recommendations](recommendations.md)
* Submissions should be well-documented.
* *Coming Soon* Submissions should be testable, and come with the required
tests.

If you have an idea for a new submission, feel free to open an issue to discuss
the idea with the catalog maintainers and community.
Once you are ready to write your submission, please open a PR with the code,
documentation and tests and a maintainer will review it.

Over time we hope to create a scalable ownership system where community members
can be responsible for maintaining their own submissions, but we are not there
yet.


### Technical requirements

* Must pass the Task validation (aka `kubectl create -f task.yaml`
  should succeed)
* Images should be published and maintained on an public image
  registry (gcr.io, docker.io, quay.io, …). A bonus if those images are
  auto-built.
* Images should not have any major security vulnerabilities
* Should follow Kubernetes best practices
* Provide as many default paramater values as possible
* Provide [end to end tests](#end-to-end-testing)
* (Nice to have) : provide versions with and without `PipelineResource`

#### End to end Testing

There is two type of e2e tests launched on CI.

The first one would just apply the yaml files making sure they don't have any
syntax issues. Pretty simple one, it just basically check the syntax.

The second one would do some proper functional testing, making sure the task
actually **ran** properly.

The way the functional tests works is that if you have a directory called
`tests/` inside the task, it would start creating a random `Namespace`, apply
the task and then every yaml files that you have in that `tests/` directory.

Note that the test runner for the integration tests will only test the tasks
that has been added or modified in the submitted PR and will not run any other
tests that hasn't been changed unless the environment variable
`TEST_RUN_ALL_TESTS` has been set.

Usually in these other yaml files you would have a yaml file for the
test resources (`PipelineResource`) and a yaml files to run the tasks
(`TaskRun or PipelineRun`).

Sometime you may need to be able to launch some scripts before applying the
tested task or the other yaml files. Some may pre-setup something on the
`Namespace` or have to do something externally or sometimes you may even want to do
some manipulation of the main `Task`.

For example on the *image builders* tasks like `kaniko` or `jib` we want to
upload the tasks to a registry to make sure it is actually built properly. To do
so we [manipulate](kaniko/tests/pre-apply-task-hook.sh) with a python script the
`Task` (something we don't want for everyone but only for the tests) to add a
registry as a `Sidecar` and make sure that the `TaskRun` set the parameters to
upload there. Simple and straightforward no need to upload to an external image
registry provider having to setup the tokens and deals with the side effects...

There is two different scripts that are checked if present in the `scripts`,
those scripts actually sourced via the `source` bash script, so you can output
some environment variables to it that would be applied :

1. **pre-apply-task-hook.sh**: Script to run before applying the task
2. **pre-apply-taskrun-hook.sh**: Script to run before applying the taskruns or other yaml files.

We have some helper functions you can use from your `hook` scripts :

* **add_sidecar_registry**: This will add a registry as a sidecar to allow the builder tasks to upload image directly to this sidecar registry instead of having to rely on external registries.
* **add_sidecar_secure_registry**: This will run a secure registry as a sidecar to allow the tasks to push to this registry using the certs. It will create
  a configmap `sslcert` with certificate available at key `ca.crt`
* **add_task**: Install a task into the testing namespace, the first argument is the name of the task, the second argument is the version of the task. If the version is equal to `latest` it will install the latest version of the task.

What can you run from those scripts is whatever defined in the test-runner
image, if you need to have another binary available feel free to make a PR to this Dockerfile :

https://github.com/tektoncd/plumbing/blob/main/tekton/images/test-runner/Dockerfile

A helper script called [`run-test.sh`](test/run-test.sh) is provider in the
[test](./test) directory to help the developer running the test locally. Just
specify the task name and the version as the first and the second argument i.e:

```bash
./test/run-test.sh git-clone 0.1
```

and it will use your kubernetes to run the test and show you the outputs as done
in the CI.

#### End to end Testing for external services

Some tasks need to be able to access some external REST api services.

There are two approaches for testing external services, the first one if you can is to spin up a deployment of the service tests and exposed as a kubernetes service and the second one is an http rest api reflector for task that connect to rest apis endpoint that cannot be available as a deployment (i.e: Saas services like github)

For the first approach, you can take the [trigger-jenkins-build test](task/trigger-jenkins-job/0.1/tests/) as an example.

You will want to modify the [pre-apply-task-hook.sh](task/trigger-jenkins-job/0.1/tests/pre-apply-task-hook.sh) script to create the deployment and make it available to your test pipelinerun.

Here is a rundown of the steps we are doing in `trigger-jenkins-build/pre-apply-task-hook.sh` script :

- Create a deployment with the `jenkins` image
- Wait until the deployment has completed.
- expose the deployment as a service, which would then be easily available for other pods in the namespace.
- Do some shenanigans inside the jenkins pod so we can grab the jenkins apikey and create a new jenkins job.
- create a secret with the apikey, username and other stuff.

The [test pipelinerun](task/trigger-jenkins-job/0.1/tests/run.yaml) for the `trigger-jenkins-build/` will then points to `http://jenkins:8080` which it the service URL where our just deployed jenkins is exposed and use the secrets credentials from the just created secret in the `pre-apply-task-hook.sh` script.

For those other services where you can't spin up a new deployment of the service easily, the test runner support the ["Go Rest api
test"](https://github.com/chmouel/go-rest-api-test) project.
The Go rest api test project is a simple service that replies back to http
requests according to rules.

As an example see the [github-add-comment task](task/github-add-comment).
For this task to be tested we need to be able to *"fake"* the Github REST api
calls. To be able to do so, we are adding a go-rest-api-test rule inside the
[testing](task/github-add-comment/0.1/tests/fixtures) repository, the rule looks
like this :

```yaml
---
headers:
  method: POST
  path: /repos/{repo:[^/]+/[^/]+}/issues/{issue:[0-9]+}/comments
response:
  status: 200
  output: '{"status": 200}'
  content-type: text/json
```

The rules is saying that for every **POST** requests going to this url :

`/repos/${ORG}/${REPO}/issues/${issues}/comments`

we will reply by a `200` status and output `{"status": 200}`

The [Pipelinerun](task/github-add-comment/0.1/tests/run.yaml) test for the
github-add-comment task overrides the github host url in its param to point to
`localhost:8080` :

```yaml
    - name: GITHUB_HOST_URL
      value: http://localhost:8080
```

In the [test runner](test/e2e-common.sh) if we find a directory called
`task/${task}/${version}/tests/fixtures` we automatically spin up the
["go-rest-api-test"](https://github.com/chmouel/go-rest-api-test) server as a
sidecar container with the test's fixtures yaml as the config. It will be then
available to the task locally to this URL `http://localhost:8080`.

The task runs against that service instead of the github servcer and the
responder replies with the right calls, we know then that the task has been
properly tested.

The only requirement to use the fixtures testing facility is to be have the task
having the capability via a task parameter to override the URL.

The `go-rest-api-test` is a very simple service at the moment and may see other
improvements in the future to support more robust testing.

### Owning and Maintaining a Task

Individual tasks should maintained by one or more users of
GitHub. When someone maintains a Task, they have the access to merge
changes to that Task. To have merge access to a Task, someone needs to:

1. Be invited (and accept your invite) as a read-only collaborator on
[the tekton organization](https://github.com/tektoncd). If you need
sponsors and have contributed to the chart, please reach out to the
existing maintainers, or if you are having trouble connecting with
them, please reach out to one of the main [OWNERS](OWNERS) of this
repository.
2. an `OWNERS` file needs to be added in the `Task` folder. That
`OWNERS` file should list the maintainers' GitHub login names for both
the reviewers and approvers sections.

## OWNERS

The top-level [`OWNERS`](OWNERS) file lists the *Trusted
Collaborators*. The process to [becoming an
OWNER](https://github.com/tektoncd/community/blob/main/process.md#owners)
is the same as other Tekton projects.
