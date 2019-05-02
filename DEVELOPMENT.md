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