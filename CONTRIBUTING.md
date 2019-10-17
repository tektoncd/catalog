# Contributing to the catalog repo

Thank you for your interest in contributing!

This doc is about how to contribute to this repo specifically. For how to
contribute to tektoncd projects in general, see [the overview in our README](README.md)
and the individual `CONTRIBUTING.md` files in each respective project.

**All contributors must comply with
[the code of conduct](./code-of-conduct.md).**

PRs are welcome, and will follow
[the tektoncd pull request process](https://github.com/tektoncd/community/blob/master/process.md#pull-request-process).

## How to Contribute a Task

1. Fork this repository, develop and test your `Task`s.
2. Create a new folder for your `Task`(s)
3. Ensure your Task follows the technical and documentation
   guidelines, described below.
4. Submit a pull request.

### Technical requirements

* Must pass the Task validation (aka `kubectl create -f task.yaml`
  should succeed)
* Images should be published and maintained on an public image
  registry (gcr.io, docker.io, quay.io, …). A bonus if those images are
  auto-built.
* Images should not have any major security vulnerabilities
* Should follow Kubernetes best practices
* Provide as many default paramater values as possible
* (Nice to have) : provide versions with and without `PipelineResource`

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
OWNER](https://github.com/tektoncd/community/blob/master/process.md#owners)
is the same as other Tekton projects.
