# Istio Workspace Delete Task

`ike-delete` removes a `ref` from a `session` object. If this is the last `ref` on the `session` the `session` will be deleted.

## `ike-delete`

### Parameters

-   `namespace`(string): Which namespace to target.

    -   default value: $(context.taskRun.namespace)

-   `target`(string): What deployment to target.

-   `session`(string): What to call the session.

### Results

<div class="note">

The task does not define any results to be consumed further in the pipeline.

</div>

### Usage

``` yaml
params:
  - name: target
    value: ratings-v1
  - name: session
    value: $(params.git-pr-head-ref)
```
