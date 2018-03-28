#!/bin/bash

[[ $# -eq 1 ]] || \
    { echo "USAGE: $0 <hostfile>"; exit 1; }

thishost=$(hostname)
jobnodes=$1
rc=0
for node in $(cat $jobnodes); do
    echo -n "CHECKING: from $thishost to $node ... "
    ssh $node hostname 2>/dev/null || \
        { echo "FAILURE"; rc=1; } ;
done
exit $rc

