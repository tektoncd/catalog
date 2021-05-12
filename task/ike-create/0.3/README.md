# Istio Workspace Create Task

`ike-create` creates a new `session` object for `istio-workspace` and will provide a private route in the cluster for the given target.

## `ike-create`

### Parameters

-   `namespace`(string): Which namespace to target.

    -   default value: $(context.taskRun.namespace)

-   `target`(string): What deployment to target.

-   `session`(string): What to call the session.

-   `route`(string): How to route.

    -   default value:

-   `image`(string): The image to use for the route.

### Results

-   `url`: The URL of the new route.

### Usage

``` yaml
params:
  - name: target
    value: ratings-v1
  - name: session
    value: $(params.git-pr-head-ref)
  - name: image
    value: quay.io/workspace-demo/$(params.git-repo-name)-ratings:$(params.git-revision)
  - name: route
    value: "header:ike-session-id=$(params.git-pr-head-ref)"
```
