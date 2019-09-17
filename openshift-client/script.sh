#!/bin/bash

set -e

command="/usr/local/bin/oc-origin"

for args in "$@"; do
    for arg in $args; do
        command+=" $arg"
    done
done

exec $command

exit 0