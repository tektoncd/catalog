#!/bin/bash

set -e

command="/usr/local/bin/oc-origin"

for arg in $1; do
    command+=" $arg"
done

exec $command

exit 0