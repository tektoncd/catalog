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
