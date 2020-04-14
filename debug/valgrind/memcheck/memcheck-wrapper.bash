#!/bin/bash

# Job utility function definitions
memcheck_dir=$(dirname $0)
source $memcheck_dir/memcheck-functions.bash

if [[ $# -eq 0 ]]; then
    echo "USAGE ERROR: $0 <app> [<arg> ...]"
    exit 1
fi

app=$1
shift
app_args="$@"

# Run under valgrind memcheck tool
jobutil_memcheck_app $app "$app_args" 

