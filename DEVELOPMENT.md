# Developing additions to the Catalog

The Catalog repository is intended to serve as a location where users can find
`Task`s and `Pipeline`s that are maintained, useful and follow established
best practices.

When reviewing PRs that add new `Task`s or `Pipeline`s, maintainers will follow
the following guidelines:

* Submissions should be useful in real-world applications.
While this repository is meant to be educational, its primary goal is to serve
as a place users can find, share and discover useful components.
This is **not** a samples repo to showcase Tekton features, this is a collection
* Submissions should follow established best practices.
Tekton is still young so this is going to be a shifting goalpost, but here are
some examples:
    * `Task`s should expose parameters and declare input/output resources, and
    document them.
    * Submissions should be as *portable* as possible.
    They should not be hardcoded to specific repositories, clusters,
    environments etc.
    * Images should either be pinned by digest or point to tags with
    documented maintenance policies.
    The goal here is to make it so that submissions keep working.
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


# End to end Testing

There is two type of e2e tests launched on CI.

The first one would just apply the yaml files making sure they don't have any
syntax issues. Pretty simple one, it just basically check the syntax.

The second one would do some proper functional testing, making sure the task
actually **ran** properly.

The way the functional tests works is that if you have a directory called
`tests/` inside the task, it would start creating a random `Namespace`, apply
the task and then every yaml files that you have in that `tests/` directory.

Usually in these other yaml files you would have a yaml file for the
test resources (`PipelineResource`) and a yaml files to run the tasks
(`TaskRun`).

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

What can you run from those scripts is whatever defined in the test-runner
image, if you need to have another binary available feel free to make a PR to this Dockerfile :

https://github.com/tektoncd/plumbing/blob/master/prow/images/test-runner/Dockerfile
