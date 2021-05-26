# Embed your script in external files

This is a small script that helps you manage your embedded [scripts
](https://github.com/tektoncd/pipeline/blob/main/docs/tasks.md#running-scripts-within-steps)
inside your Tekton tasks externally.

## Install

You need the [ruamel.yaml](https://yaml.readthedocs.io/en/latest/) library, it
should be availabe in fedora/debian default repositories or you can simply use
pip to install it :

```shell
pip3 install ruamel.yaml
```

## Usage

If for example you have a task like this :

```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: git-clone
spec:
  steps:
    - name: step1
      script: "#include script.sh"
```

The "embed_script" script will see it and includes the `script.sh` in place of
your `"#include script.sh"`.

At the end it will print every yaml documents even the ones who have not been
substituted from includes. Each document will be separated with a `"---"`
separator.

## CAVEAT

It doesn't support embedded `TaskSpec` or `PipelineSpec` yet but there is no
reason this cannot be supported.
