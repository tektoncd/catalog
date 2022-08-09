# description

Executes a script(e.g bash, python etc) and exposes stderr, stdout and exit_code as results.
In the default image bash version 5 is installed

# parameters

## script_source
Mandatory:
Bash script source code (multiline)-string.
Will be copied to a file and then executed via '/var/myScript', so please specify a shebang line, e.g.:
`#!/usr/bin/env bash`

## image
Optional:
Image that this task runs on.
The default image contains GNU bash, version 5.1.4(1)-release (x86_64-pc-linux-gnu).

Default: "debian:bullseye@sha256:2ce44bbc00a79113c296d9d25524e15d423b23303fdbbe20190d2f96e0aeb251"

## trace
Optional: Enable tracing (executes set -x).
Note that in your script_source you will need to turn on tracing independently, this is only meant for
debugging this tasks' code.

Default: "false"

# results

## stdout
script standard output

## stderr
script error output

## exit_code
Script exit code, note however that the task will fail (with the exit code of the failed script) in case of
failure and then the result will not be accessible, because a failed tekton task has no results atm!

# workspaces
Optionally, any number of workspaces up to three may be provided, with any of those names:
- workspace-a
- workspace-b
- workspace-c

