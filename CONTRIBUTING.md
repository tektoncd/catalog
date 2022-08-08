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

## How to Contribute a new version of a Task or Pipeline

If you are planning to add a new version of a Task or Pipeline make sure to
separate your changes from the copied task. This makes it easy for reviewers to
review the changes and not the actual copy.

For example if you have to bump the catalog task called `foo` from `0.1` to
`0.2` you simply first copy the old task :

```shell
% cp -a tasks/foo/0.1 tasks/foo/0.2
```

and then immediately commit that change :

```shell
% git add tasks/foo/0.2
% git commit -m "Copy task foo from 0.1 to 0.2
```

and then add your change and commit it.

This will result to a clean git log and makes it easier to only see your
changes.

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

There are two types of e2e tests launched on CI.

The first one would just apply the yaml files making sure they don't have any
syntax issues. Pretty simple one, it just basically checks the syntax.

The second one would do some proper functional testing, making sure the task
actually **ran** properly.

The way the functional tests works is that if you have a directory called
`tests/` inside the task, CI will create a random `Namespace` then apply
the task and then every yaml file in the `tests/` directory.

Note that the test runner for the integration tests will only test the tasks
that have been added or modified in the submitted PR and will not run tests for
any tasks that haven't been changed unless the environment variable
`TEST_RUN_ALL_TESTS` has been set.

Usually in these other yaml files you would have a yaml file for the
test resources (`PipelineResource`) and a yaml files to run the tasks
(`TaskRun or PipelineRun`).

Sometimes you may need to be able to run scripts before applying the tested task
or the other yaml files. For example, your tests may need pre-setup in the
`Namespace`, external setup, or perhaps even manipulation of the main `Task`.

For example on *image builders* tasks like `kaniko` or `jib` we want to upload
the tasks to a registry to make sure it is actually built properly. To do so, we
[manipulate](task/kaniko/0.6/tests/pre-apply-task-hook.sh) the `Task` with a
python script (something we only want for the tests) to add a registry as a
`Sidecar` and make sure that the `TaskRun` sets the parameters to upload there.
This is simple and straightforward -- there is no need to upload to an external
image registry provider which would require settin up tokens and dealing with
both side effects and an external dependency.

There are two different scripts that are automatically applied if present. These
are applied using the `source` bash script, so you can output environment
variables that will be applied:

1. **pre-apply-task-hook.sh**: Script to run before applying the task
2. **pre-apply-taskrun-hook.sh**: Script to run before applying the taskruns or other yaml files.

We have some helper functions you can use from your `hook` scripts:

* **add_sidecar_registry**: This will add a registry as a sidecar to allow the
  builder tasks to upload an image directly to this sidecar registry instead of
  relying on an external registries.
* **add_sidecar_secure_registry**: This will run a secure registry as a sidecar
  to allow the tasks to push to this registry using certs. It will create a
  configmap `sslcert` with certificate available at key `ca.crt`
* **add_task**: Install a task into the testing namespace, the first argument is
  the name of the task, the second argument is the version of the task. If the
  version is equal to `latest` it will install the latest version of the task.

What can you run from those scripts is defined in the test-runner image. If you
need to have another binary available, make a PR to this `Dockerfile`:

https://github.com/tektoncd/plumbing/blob/main/tekton/images/test-runner/Dockerfile

A helper script called [`run-test.sh`](test/run-test.sh) is provider in the
[test](./test) directory to help the developer running the test locally. Just
specify the task name and the version as the first and the second argument i.e:

```bash
./test/run-test.sh git-clone 0.1
```

and it will use your current kubernetes context to run the test and show you the
outputs similar to the CI.

#### End to end Testing for external services

Some tasks need to be able to access some external REST api services.

There are two approaches for testing external services:

1. Spin up a deployment of the service tests and expose a kubernetes service.
2. Create an http rest api reflector for task that connects to a rest apis
   endpoint that cannot be available as a deployment (i.e: Saas services like
   github)

For the first approach, you can take the [trigger-jenkins-build
test](task/trigger-jenkins-job/0.1/tests/) as an example.

You will want to modify the
[pre-apply-task-hook.sh](task/trigger-jenkins-job/0.1/tests/pre-apply-task-hook.sh)
script to create the deployment and make it available to your test `PipelineRun`.

Here is a rundown of the steps we are doing in `trigger-jenkins-build/pre-apply-task-hook.sh` script :

- Create a deployment with the `jenkins` image
- Wait until the deployment has completed.
- Expose the deployment as a service, which would then be easily available for
  other pods in the namespace.
- Do some shenanigans inside the jenkins pod so we can grab the jenkins apikey
  and create a new jenkins job.
- Create a secret with the apikey, username and other items.

The [test pipelinerun](task/trigger-jenkins-job/0.1/tests/run.yaml) for the
`trigger-jenkins-build/` will then point to `http://jenkins:8080` which is the
service URL where our just deployed jenkins is exposed. It uses the credentials
from the secret in the `pre-apply-task-hook.sh` script.

For services where you can't spin up a new deployment of the service easily, the
test runner supports the ["Go Rest api
test"](https://github.com/chmouel/go-rest-api-test) project.  The Go rest api
test project is a simple service that replies back to http requests according to
rules.

As an example see the [github-add-comment task](task/github-add-comment).
For this task to be tested we need to be able to *"fake"* the Github REST api
calls. To be able to do so, we are adding a go-rest-api-test rule inside the
[testing](task/github-add-comment/0.1/tests/fixtures) repository; the rule looks
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

The rule is saying that for every **POST** requests going to this url :

`/repos/${ORG}/${REPO}/issues/${issues}/comments`

we will reply by a `200` status and output `{"status": 200}`

The [Pipelinerun](task/github-add-comment/0.1/tests/run.yaml) test for the
`github-add-comment` task overrides the github host url in its param to point to
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

The only requirement to use the fixtures testing facility is to enable the task
to override the URL via a task parameter.

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
