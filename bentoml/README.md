### Examples

Run `bentoml --help` for BentoML usage. Using the Tekton CLI (`tkn`):

```shell
tkn task start bentoml -p ARGS=ad,--help
```

Specify a different `az-image` to use with the `az` task:

```shell
tkn task start bentoml -p args="i dont know yet"
```
