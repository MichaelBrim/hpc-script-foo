# bash script - source this file

export jutil_info="==== JOB UTIL INFO ===="
export jutil_err="==== JOB UTIL ERROR ===="
export jutil_warn="==== JOB UTIL WARNING ===="

# datestamp()
# - capture current timestamp in a format suitable for file names
function jobutil_datestamp {
    # USAGE: timestamp=$(jobutil_datestamp)
    date +'%F_%T' | sed -e 's/://g'
}
declare -fx jobutil_datestamp

# ipv4_addr(subnet_prefix)
# - looks up local IPv4 address that corresponds to given $subnet_prefix
function jobutil_ipv4_addr {
    # USAGE: ipaddr=$(jobutil_ipv4_addr <subnet-prefix>)
    #  e.g., jobutil_ipv4_addr 192.168.1.
    if [[ $# -ne 1 ]]; then
        echo >&2 "$jutil_err USAGE: jobutil_ipv4_addr subnet-prefix"
        return 1
    fi

    ip -4 addr | fgrep inet | fgrep $1 | awk '{ split($2,ip,"/"); print ip[1]} '
}
declare -fx jobutil_ipv4_addr

# short_hostname([fqdn])
# - returns hostname portion of a given fully-qualified domain name,
#   or the current host
function jobutil_short_hostname {
    # USAGE: short_host=$(jobutil_short_hostname [<fqdn>])
    if [[ $# -eq 1 ]]; then
        my_targ_host=$1
    else
        my_targ_host=$(hostname)
    fi
    ipv4_pattern='^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
    if [[ $my_targ_host =~ $ipv4_pattern ]]; then
        my_short_host=$my_targ_host
    else
        my_short_host=$(echo $my_targ_host | awk -F'.' '{print $1}')
    fi
    echo $my_short_host
}
declare -fx jobutil_short_hostname

# kill_proc(target_process_name, logfile)
# - kills all processes whose executable matches $target_process_name
# - logs actions to $logfile
function jobutil_kill_proc {
    # USAGE: jobutil_kill_proc <target-process-name> <logfile>
    if [[ $# -ne 2 ]]; then
        echo >&2 "$jutil_err USAGE: jobutil_kill_proc target-process-name logfile"
        return 1
    fi
    
    local my_targ_proc=$1
    local my_log=$2
    my_kill_pids=$(pgrep -x $my_targ_proc)
    if [[ -z $my_kill_pids ]]; then
        my_short_targ=$(echo $my_targ_proc | cut -c1-15)
        my_kill_pids=$(pgrep -x $my_short_targ)
    fi
    if [[ -n $my_kill_pids ]]; then
        for kpid in $my_kill_pids; do
            if [[ $$ -ne $kpid && $PPID -ne $kpid ]]; then
                my_kpid_info=$(ps -fp $kpid)
                echo "@ $(jobutil_datestamp) - killing $my_targ_proc process:" >> $my_log
                echo "$my_kpid_info" >> $my_log
                kill $kpid >> $my_log 2>&1
            fi
        done
    fi
}
declare -fx jobutil_kill_proc

# resolve_full_path(target_file)
# - gets absolute path to $target_file by resolving all relative
#   path components and symlinks
function jobutil_resolve_full_path {
    # USAGE: abspath=$(jobutil_resolve_full_path <target-file>)
    if [[ $# -ne 1 ]]; then
        echo >&2 "$jutil_err USAGE: jobutil_resolve_full_path target-file"
        return 1
    fi

    # $1 is target file
    local my_targ="$1"
    
    # resolve $my_targ until the file is no longer a symlink
    while [[ -h $my_targ ]]; do
        my_dir="$( cd -P "$( dirname "$my_targ" )" && pwd )"
        my_targ="$(readlink "$my_targ")"
        # if relative symlink, resolve relative to dir containing symlink
        [[ $my_targ != /* ]] && my_targ="$my_dir/$my_targ" 
    done

    # get full path to containing dir
    my_dir="$( cd -P "$( dirname "$my_targ" )" && pwd )"

    # get base file name
    my_base="$( basename "$my_targ" )"

    # echo full path to file
    echo "$my_dir/$my_base"
}
declare -fx jobutil_resolve_full_path

# directory_diskusage(target_dir, log_dir)
# - runs du on $target_dir
# - captures output in $log_dir/diskusage file
function jobutil_directory_diskusage {
    # USAGE: jobutil_directory_diskusage target-dir log-dir
    local du_targetdir=$1
    local du_logdir=$2

    if [[ ! -x $du_targetdir ]] ; then
        echo >&2 "$jutil_err $du_targetdir does not exist, cannot run"
        return 1
    fi

    if [[ ! -d $du_logdir ]] ; then
        echo >&2 "$jutil_warn $du_logdir does not exist, will try to create"
        mkdir -p $du_logdir
        if [[ $? -ne 0 ]] ; then
            echo >&2 "$jutil_err implicit creation of $du_logdir failed"
            return 2
        fi
    fi

    echo "----- $du_targetdir -----" >> ${du_logdir}/diskusage
    du --si --max-depth=2 $du_targetdir >> ${du_logdir}/diskusage 2>&1
    echo >> ${du_logdir}/diskusage
}
declare -fx jobutil_directory_diskusage

# timed_run(run_cmd, run_args, app, app_args, app_logdir)
# - uses "$run_cmd $run_args" to execute "$app $app_args"
# - measures runtime using bash time built-in
# - captures app stdio and timing info in files in $app_logdir
function jobutil_timed_run {
    local run_cmd=$1
    local run_args="$2"
    local app=$3
    local app_args="$4"
    local app_logdir=$5

    type -t $run_cmd >/dev/null 2>&1
    if [[ $? -ne 0 ]] ; then
        echo >&2 "$jutil_err $run_cmd not executable"
        return 1
    fi

    if [[ ! -x $app ]] ; then
        echo >&2 "$jutil_err $app does not exist or is not an executable, cannot run"
        return 1
    fi

    if [[ ! -d $app_logdir ]] ; then
        echo >&2 "$jutil_warn $app_logdir does not exist, will try to create"
        mkdir -p $app_logdir
        if [[ $? -ne 0 ]] ; then
            echo >&2 "$jutil_err implicit creation of $app_logdir failed"
            return 2
        fi
    fi

    local now=$(jobutil_datestamp)
    local full_cmd="$run_cmd $run_args $app $app_args"
    local appbase=$(basename $app)
    local applog=${app_logdir}/${appbase}.run.${now}.log
    local apptime=${app_logdir}/${appbase}.run.${now}.time

    export TIMEFORMAT='elapsed=%3lR'
    echo >&2 "$jutil_info Running application: $full_cmd"
    echo -n "started=$now," > $apptime
    (time $run_cmd $run_args $app $app_args > $applog 2>&1) 2>> $apptime ; appret=$?
    echo >&2 "$jutil_info Application exit status: $appret"
    echo >&2 "$jutil_info Application timing:" $(cat $apptime)
    return $appret
}
declare -fx jobutil_timed_run

# timed_run_with_timeout(run_cmd, run_args, app, app_args, app_logdir, timeout_secs)
# - uses "$run_cmd $run_args" to execute "$app $app_args"
# - captures app stdio and timing info in files in $app_logdir
# - measures runtime using bash time built-in
# - kills $run_cmd if $timeout_secs exceeded
function jobutil_timed_run_with_timeout {
    local run_cmd=$1
    local run_args="$2"
    local app=$3
    local app_args="$4"
    local app_logdir=$5
    local timeout_secs=$6

    type -t $run_cmd >/dev/null 2>&1
    if [[ $? -ne 0 ]] ; then
        echo >&2 "$jutil_err $run_cmd not executable"
        return 1
    fi

    if [[ ! -x $app ]] ; then
        echo >&2 "$jutil_err $app does not exist or is not an executable, cannot run"
        return 1
    fi

    if [[ ! -d $app_logdir ]] ; then
        echo >&2 "$jutil_warn $app_logdir does not exist, will try to create"
        mkdir -p $app_logdir
        if [[ $? -ne 0 ]] ; then
            echo >&2 "$jutil_err implicit creation of $app_logdir failed"
            return 2
        fi
    fi

    local now=$(jobutil_datestamp)
    local full_cmd="$run_cmd $run_args $app $app_args"
    local appbase=$(basename $app)
    local applog=${app_logdir}/${appbase}.run.${now}.log
    local apptime=${app_logdir}/${appbase}.run.${now}.time

    export TIMEFORMAT='elapsed=%3lR'
    echo >&2 "$jutil_info Running application: $full_cmd"
    echo -n "started=$now," > $apptime
    time ( $run_cmd $run_args $app $app_args >$applog 2>&1 &
      local child=$!
      trap -- "" SIGTERM
      ( sleep $timeout_secs
        kill $child ) >/dev/null 2>&1 &
      wait $child
    ) 2>> $apptime
    appret=$?
    if [[ $appret -gt 128 ]]; then
        appsig=$(expr $appret - 128)
        appstat="killed by signal $appsig"
    else
        appstat="$appret"
    fi
    echo >&2 "$jutil_info Application exit status: $appstat"
    echo >&2 "$jutil_info Application timing:" $(cat $apptime)
    return $appret
}
declare -fx jobutil_timed_run_with_timeout
