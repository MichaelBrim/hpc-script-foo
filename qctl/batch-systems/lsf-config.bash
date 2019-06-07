qctl_cancel_job () {
    local job=$1
    local cmd="bkill"
    echo "$cmd $job"
}

qctl_cancel_queue () {
    local que=$1
    local usr=$2
    local cmd="bkill"
    echo "$cmd -q $que -u $usr 0"
}

qctl_detail_job () {
    local job=$1
    local cmd="bjobs -l"
    echo "$cmd $job"
}

qctl_detail_queue () {
    local que=$1
    local cmd="bjobs -a -u all"
    echo "$cmd -q $que"
}

qctl_hold_job () {
    local job=$1
    local cmd="bstop"
    echo "$cmd $job"
}

qctl_hold_queue () {
    local que=$1
    local usr=$2
    local cmd="bstop"
    echo "$cmd -q $que -u $usr 0"
}

qctl_resume_job () {
    local job=$1
    local cmd="bresume"
    echo "$cmd $job"
}

qctl_resume_queue () {
    local que=$1
    local usr=$2
    local cmd="bresume"
    echo "$cmd -q $que -u $usr 0"
}

qctl_status_hosts () {
    local cmd="bhosts"
    echo "$cmd"
}

qctl_status_job () {
    local job=$1
    local cmd="bjobs"
    echo "$cmd $job"
}

qctl_status_project () {
    local prj=$1
    local que=$2
    local cmd="bjobs -a"
    [[ -n $que ]] && cmd="$cmd -q $que"
    echo "$cmd -P $prj"
}

qctl_status_queue () {
    local que=$1
    local cmd="bqueues"
    [[ -n $que ]] && cmd="bjobs -u all -q $que"
    echo "$cmd"
}

qctl_status_user () {
    local usr=$1
    local que=$2
    local cmd="bjobs -a"
    [[ -n $que ]] && cmd="$cmd -q $que"
    echo "$cmd -u $usr"
}

qctl_submit_batch () {
    local que=$1
    local prj=$2
    local wt=$3
    local nn=$4
    local js=$5
    local cmd="bsub"
    [[ -n $que ]] && cmd="$cmd -q $que"
    [[ -n $prj ]] && cmd="$cmd -P $prj"
    [[ -n $wt ]]  && cmd="$cmd -W $wt"
    [[ -n $nn ]]  && cmd="$cmd -nnodes $nn"
    echo "$cmd $js"
}

qctl_submit_interactive () {
    local que=$1
    local prj=$2
    local wt=${3:-15}
    local nn=${4:-1}
    local cmd="bsub"
    [[ -n $que ]] && cmd="$cmd -q $que"
    [[ -n $prj ]] && cmd="$cmd -P $prj"
    cmd="$cmd -W $wt -nnodes $nn"
    echo "$cmd -Is /bin/bash"
}

