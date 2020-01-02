# tkn

This task performs operations on Tekton resources using
[`tkn`](https://github.com/tektoncd/cli).

## Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/tkn/tkn.yaml
```

## Inputs

### Parameters

name      | description                                 | default
--------- | ------------------------------------------- | -------
tkn-image | `tkn` CLI container image to run this task. | gcr.io/tekton-releases/dogfooding/tkn
ARGS      | The arguments to pass to the `tkn` CLI.     | No default. Required.
