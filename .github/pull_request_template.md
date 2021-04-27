<!-- 🎉🎉🎉 Thank you for the PR!!! 🎉🎉🎉 -->

# Changes

<!-- Describe your changes here- ideally you can get that description straight from
your descriptive commit message(s)! -->

# Submitter Checklist

These are the criteria that every PR should meet, please check them off as you
review them:

- [ ] Follows the [authoring recommendations](https://github.com/tektoncd/catalog/blob/main/recommendations.md)
- [ ] Includes [docs](https://github.com/tektoncd/community/blob/master/standards.md#principles) (if user facing)
- [ ] Includes [tests](https://github.com/tektoncd/community/blob/master/standards.md#principles) (if functionality of task changed or new task added)
- [ ] Commit messages follow [commit message best practices](https://github.com/tektoncd/community/blob/master/standards.md#commit-messages)
- [ ] Complies with [Catalog Organization TEP][TEP], see [example]. **Note** [An issue has been filed to automate this validation][validation]
  - [ ] File path follows  `<kind>/<name>/<version>/name.yaml`
  - [ ] Has `README.md` at `<kind>/<name>/<version>/README.md`
  - [ ] Has mandatory `metadata.labels` - `app.kubernetes.io/version` the same as the `<version>` of the resource
  - [ ] Has mandatory `metadata.annotations` `tekton.dev/pipelines.minVersion`
  - [ ] mandatory `spec.description` follows the convention

          ```

          spec:
            description: >-
              one line summary of the resource

              Paragraph(s) to describe the resource.
          ```

_See [the contribution guide](https://github.com/tektoncd/catalog/blob/master/CONTRIBUTING.md)
for more details._

---

[TEP]: https://github.com/tektoncd/community/blob/master/teps/0003-tekton-catalog-organization.md
[example]: https://github.com/tektoncd/catalog/tree/master/task/git-clone/0.1
[validation]:  https://github.com/tektoncd/catalog/issues/413
