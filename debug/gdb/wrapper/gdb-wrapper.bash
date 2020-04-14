#!/bin/bash

gdb_dir=$(dirname $0)
source $gdb_dir/gdb-functions.bash

if [[ $# -eq 0 ]]; then
    echo "USAGE ERROR: $0 <app> [<arg> ...]"
    exit 1
fi

app=$1
shift
app_args="$@"

# Run under debugger
jobutil_debug_app $app "$app_args"

