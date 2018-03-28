#!/bin/bash

if [[ $# -eq 0 ]]; then
    echo "USAGE ERROR: $0 <app> [<arg> ...]"
    exit 1
fi

app=$1
shift
app_args="$@"

# Job utility function definitions

export jutil_info="==== JOB UTIL INFO ===="
export jutil_err="==== JOB UTIL ERROR ===="
export jutil_warn="==== JOB UTIL WARNING ===="

function jobutil_short_hostname {
    # USAGE: jobutil_short_hostname [FQDN]
    if [[ $# -eq 1 ]]; then
        targ_host=$1
    else
        targ_host=$(hostname)
    fi
    ipv4_pattern='^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
    if [[ $targ_host =~ $ipv4_pattern ]]; then
        short_host=$targ_host
    else
        short_host=$(echo $targ_host | awk -F'.' '{print $1}')
    fi
    echo $short_host
}
declare -fx jobutil_short_hostname

function jobutil_resolve_full_path {
    # USAGE: jobutil_resolve_full_path target-file
    if [[ $# -ne 1 ]]; then
        echo >&2 "$jutil_err USAGE: jobutil_resolve_full_path target-file"
        return 1
    fi

    # $1 is target file
    my_targ="$1"
    
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

function jobutil_debug_daemon {
    # USAGE: jobutil_debug_daemon exe-path "args"
    if [[ $# -ne 2 ]]; then
        echo >&2 "$jutil_err USAGE: jobutil_debug_daemon exe-path \"args ...\""
        return 1
    fi
    
    # $1 is daemon exe path
    my_exe=$(jobutil_resolve_full_path $1)
    my_exe_base=$(basename "$my_exe")
    my_exe_dir=$(dirname "$my_exe")

    # $2 is daemon args (may be empty)
    my_args="$2"
    
    # log to current working dir
    my_logdir=$PWD
    my_log_base=${my_logdir}/${my_exe_base}-$(jobutil_short_hostname)-$$

    dbghost=$(jobutil_short_hostname)
    echo >&2 "$jutil_info DEBUG: on $dbghost - exe=$my_exe, args=\"$my_args\", logdir=$my_logdir"

    # generate gdb batch script
    my_gdb_script=${my_log_base}.gdb-cmds
    [[ -f $my_gdb_script ]] && rm -f $my_gdb_script
    cat > $my_gdb_script <<EOS
set width 1000
set confirm off
handle SIGINT nostop pass
handle SIGQUIT nostop pass
handle SIGTERM nostop pass
run $my_args
thread apply all bt
quit
EOS

    # do it already
    gdb_args="--batch --command=$my_gdb_script"
    gdb_exec="gdb"
    [[ -d "$my_exe_dir/.libs" ]] && gdb_exec="libtool --mode=execute $gdb_exec"
    echo >&2 "$jutil_info DEBUG: on $dbghost - running: $gdb_exec $gdb_args $my_exe > ${my_log_base}.gdb-log"
    $gdb_exec $gdb_args $my_exe > ${my_log_base}.gdb-log 2>&1 & 
}
declare -fx jobutil_debug_daemon

# Run under debugger
jobutil_debug_daemon $app "$app_args" 

