slurm_walltime() {
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
    local cmd="scancel"
    echo "$cmd $job"
}

qctl_detail_job () {
    local job=$1
    local cmd="squeue -l"
    echo "$cmd -j $job"
}

qctl_detail_queue () {
    local que=$1
    local cmd="squeue -l"
    echo "$cmd -p $que"
}

qctl_hold_job () {
    local job=$1
    local cmd="scontrol hold"
    echo "$cmd $job"
}

qctl_resume_job () {
    local job=$1
    local cmd="scontrol release"
    echo "$cmd $job"
}

qctl_status_hosts () {
    local que=$1
    local cmd="sinfo -N"
    [[ -n $que ]] && cmd="$cmd -p $que"
    echo $cmd
}

qctl_status_job () {
    local job=$1
    local cmd="squeue"
    echo "$cmd -j $job"
}

qctl_status_queue () {
    local que=$1
    local cmd="squeue"
    [[ -n $que ]] && cmd="$cmd -p $que"
    echo $cmd
}

qctl_status_user () {
    local usr=$1
    local que=$2
    local cmd="squeue"
    [[ -n $que ]] && cmd="$cmd -p $que"
    echo "$cmd -u $usr"
}

qctl_submit_batch () {
    local que=$1
    local prj=$2
    local wt=$3
    local nn=$4
    local js=$5
    local cmd="sbatch"
    [[ -n $que ]] && cmd="$cmd -p $que"
    [[ -n $prj ]] && cmd="$cmd -A $prj"
    [[ -n $wt ]]  && cmd="$cmd -t $(slurm_walltime $wt)"
    [[ -n $nn ]]  && cmd="$cmd -N $nn"
    echo $cmd $js
}

qctl_submit_interactive () {
    local que=$1
    local prj=$2
    local wt=${3:-15}
    local nn=${4:-1}
    local cmd="salloc"
    [[ -n $que ]] && cmd="$cmd -p $que"
    [[ -n $prj ]] && cmd="$cmd -A $prj"
    cmd="$cmd -t $(slurm_walltime $wt) -N $nn"
    echo $cmd
}

