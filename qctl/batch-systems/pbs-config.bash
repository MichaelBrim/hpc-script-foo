pbs_walltime() {
    local min=$1
    local hr=$(expr $min / 60)
    if [[ $hr -gt 0 ]]; then
        min=$(expr $min - \( $hr \* 60 \) )
        [[ $min -lt 10 ]] && min="0$min"
        echo "${hr}:${min}:00"
    else
        echo "${min}:00"
    fi
}

qctl_cancel_job () {
    local job=$1
    local cmd="qdel"
    echo "$cmd $job"
}

qctl_detail_job () {
    local job=$1
    local cmd="qstat -f"
    echo "$cmd $job"
}

qctl_detail_queue () {
    local que=$1
    local cmd="qstat -a"
    echo "$cmd $que"
}

qctl_hold_job () {
    local job=$1
    local cmd="qhold"
    echo "$cmd $job"
}

qctl_resume_job () {
    local job=$1
    local cmd="qrls"
    echo "$cmd $job"
}

qctl_status_job () {
    local job=$1
    local cmd="qstat"
    echo "$cmd $job"
}

qctl_status_queue () {
    local que=$1
    local cmd="qstat -q"
    echo "$cmd $que"
}

qctl_status_user () {
    local usr=$1
    local cmd="qstat -u"
    echo "$cmd $usr"
}

qctl_submit_batch () {
    local que=$1
    local prj=$2
    local wt=$3
    local nn=$4
    local js=$5
    local cmd="qsub -V"
    [[ -n $que ]] && cmd="$cmd -q $que"
    [[ -n $prj ]] && cmd="$cmd -A $prj"
    [[ -n $wt ]]  && cmd="$cmd -lwalltime=$(pbs_walltime $wt)"
    [[ -n $nn ]]  && cmd="$cmd -lnodes=$nn"
    echo "$cmd $js"
}

qctl_submit_interactive () {
    local que=$1
    local prj=$2
    local wt=${3:-15}
    local nn=${4:-1}
    local cmd="qsub -V -I"
    [[ -n $que ]] && cmd="$cmd -q $que"
    [[ -n $prj ]] && cmd="$cmd -A $prj"
    cmd="$cmd -lwalltime=$(pbs_walltime $wt),nodes=$nn"
    echo $cmd
}
