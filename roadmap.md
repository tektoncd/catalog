# Tekton Catalog Roadmap

This doc describes the roadmap for [the Tekton Catalog](https://github.com/tektoncd/catalog).

The catalog is a key piece of
[Tekton's mission](https://github.com/tektoncd/community/blob/main/roadmap.md#mission-and-vision).

In 2019 we got a solid start on a catalog of reusable `Tasks` and in 2020 our ecosystem grew and
a lot many `Tasks` were added in the catalog. Also our catalog was restructured so that `Tasks` present
in the catalog could be versioned and tools like [`hub`](https://hub.tekton.dev) was able to display
those tasks in a clean and better way. In 2021 we want to keep this momentum going and make the catalog
even more useful by adding:

- A clear story around ownership of components
- [Support for custom catalogs](https://docs.google.com/document/d/1O8VHZ-7tNuuRjPNjPfdo8bD--WDrkcz-lbtJ3P8Wugs/edit#)
- Support for more components, e.g. `Pipelines` and `TriggerTemplates` in
  addition to `Tasks`.
- Break the catalog into support tiers as per [TEP-0003](https://github.com/tektoncd/community/blob/main/teps/0003-tekton-catalog-organization.md#support-tiers)
  so that we can provide more confidence to users using the resources from catalog.
- Increased confidence in component quality through:
  - Clear testing requriements
  - Support for testing components that depend on external services
- Increased documentation and examples
- Well defined Tekton API conformance
