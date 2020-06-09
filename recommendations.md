# Task Authoring Recommendations

This is a collection of recommendations for developers authoring Tasks, with
justifications for why they are recommended.

These are just _recommendations_, and there may be situations where the
recommendation cannot or should not be followed.

This is a living document. Recommendations may be added in the future, or
existing recommendations may change or be clarified.

If you have a question or would like to add a recommendation, please [file an
issue](https://github.com/tektoncd/catalog/issues/new).

## Reference Images by Digest

Where possible, an image used in a step should be referenced by digest (i.e.,
`busybox@sha256:abcde...`) instead of by tag (`busybox:latest`). This ties the
Task to the exact specific version of the image, and prevents unexpected
changes.

Referencing by tag (`:latest` or `:v1.2.3`) means that an owner of that image
can push a new image to that tag, and all Tasks that reference the image by
that tag will start using it immediately. This can lead to unexpected Task
failures, or silent behavior changes, including security-sensitive changes.

## Run as non root and non privileged

One of the security best practices of containers is to run them as a
non-root user. Usually this is achieved by having a user defined in
your image and having it referred in your image configuration. You can
see
[here](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#user)
for details on best practice with `Dockerfile`s.

You should also avoid as much as possible to run containers as
[privileged](https://stackoverflow.com/questions/36425230/privileged-containers-and-capabilities).

> The --privileged flag gives all capabilities to the container, and
> it also lifts all the limitations enforced by the device cgroup
> controller. In other words, the container can then do almost
> everything that the host can do. This flag exists to allow special
> use-cases, like running Docker within Docker.

On the catalog, this means that you should, where possible:
- **ensure the image you are using can run as non-root** ; any step
  that do not specify explicitly that it needs to be run as root
  should work when running as a user.
- if your step really need to be run as root, specify it in the task
  using
  [`securityContext`](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/),
  same applies for `privileged`.

  ```yaml
  # […]
    steps:
    - name: foo
      image: myimage
      securityContext:
        runAsUser: 0 # root uid == 0
        privileged: true
  ```
