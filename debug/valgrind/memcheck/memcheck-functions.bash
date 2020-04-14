# source this file

# Job utility variable definitions

export jutil_info="==== JOB UTIL INFO ===="
export jutil_err="==== JOB UTIL ERROR ===="
export jutil_warn="==== JOB UTIL WARNING ===="

# Job utility function definitions

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

function jobutil_memcheck_app {
    # USAGE: jobutil_memcheck_app app-executable-path "app args"
    if [[ $# -ne 2 ]]; then
        echo >&2 "$jutil_err USAGE: jobutil_memcheck_app app-exe-path \"app args ...\""
        return 1
    fi

    # $1 is application exe path
    my_exe=$(jobutil_resolve_full_path $1)
    my_exe_base=$(basename "$my_exe")
    my_exe_dir=$(dirname "$my_exe")

    # $2 is application args (may be empty)
    my_args="$2"

    # log to current directory
    my_host=$(jobutil_short_hostname)
    my_logdir=$PWD
    my_log_base=${my_logdir}/${my_exe_base}-${my_host}-$$

    echo >&2 "$jutil_info MEMCHECK: on $my_host - exe=$my_exe, args=\"$my_args\", logdir=$my_logdir"

    # do it already
    mc_exec="valgrind --tool=memcheck"
    mc_args="--leak-check=no --keep-stacktraces=alloc-then-free"
    [[ -d "$my_exe_dir/.libs" && -x $my_exe_dir/.libs/$my_exe_base ]] && mc_exec="libtool --mode=execute $mc_exec"
    echo >&2 "$jutil_info MEMCHECK: on $my_host - running: $mc_exec $mc_args $my_exe > ${my_log_base}.memcheck-log"
    $mc_exec $mc_args $my_exe $my_args &> ${my_log_base}.memcheck-log
}
declare -fx jobutil_memcheck_app

function jobutil_leakcheck_app {
    # USAGE: jobutil_leakcheck_app app-executable-path "app args"
    if [[ $# -ne 2 ]]; then
        echo >&2 "$jutil_err USAGE: jobutil_leakcheck_app app-exe-path \"app args ...\""
        return 1
    fi

    # $1 is application exe path
    my_exe=$(jobutil_resolve_full_path $1)
    my_exe_base=$(basename "$my_exe")
    my_exe_dir=$(dirname "$my_exe")

    # $2 is application args (may be empty)
    my_args="$2"

    # log to current directory
    my_host=$(jobutil_short_hostname)
    my_logdir=$PWD
    my_log_base=${my_logdir}/${my_exe_base}-${my_host}-$$

    echo >&2 "$jutil_info LEAKCHECK: on $my_host - exe=$my_exe, args=\"$my_args\", logdir=$my_logdir"

    # do it already
    mc_exec="valgrind --tool=memcheck"
    mc_args="--leak-check=full --show-leak-kinds=all"
    [[ -d "$my_exe_dir/.libs" && -x $my_exe_dir/.libs/$my_exe_base ]] && mc_exec="libtool --mode=execute $mc_exec"
    echo >&2 "$jutil_info MEMCHECK: on $my_host - running: $mc_exec $mc_args $my_exe > ${my_log_base}.leakcheck-log"
    $mc_exec $mc_args $my_exe $my_args &> ${my_log_base}.leakcheck-log
}
declare -fx jobutil_leakcheck_app

