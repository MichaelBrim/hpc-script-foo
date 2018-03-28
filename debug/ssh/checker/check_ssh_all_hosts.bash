#!/bin/bash

[[ $# -eq 1 ]] || \
    { echo "USAGE: $0 <hostfile>"; exit 1; }

jobnodes=$1
scriptdir=$(dirname $0)

rc=0
for node in $(cat $jobnodes); do
    ssh $node ${scriptdir}/check_ssh.bash $jobnodes || \
        { echo "$0: FAILURE: on node $node"; rc=1; } ;
done
exit $rc

