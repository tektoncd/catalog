# Istio Workspace Session Url Task

`ike-session-url` is a convenient way to get a hold of the exposed URL for the a given `session`.

## `ike-session-url`

### Parameters

-   `namespace`(string): Which namespace to target.

    -   default value: $(context.taskRun.namespace)

-   `session`(string): What to call the session.

### Results

-   `url`: The URL of the new route.

### Usage

``` yaml
params:
  - name: session
    value: $(params.git-pr-head-ref)
```
