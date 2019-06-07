#!/bin/bash

print_usage () {
  echo "$0 <action> [<action-options>]"
  echo
  echo "  Actions     Options"
  echo "--------------------------------------------"
  echo "  config      N/A"
  echo "  cancel      -j <jobid> | -q <queue>"
  echo "  detail      -j <jobid> | -q <queue>"
  echo "  hold        -j <jobid> | -q <queue>"
  echo "  hosts       N/A"
  echo "  resume      -j <jobid> | -q <queue>"
  echo "  status      -j <jobid> | -p <project> | -q <queue> | -u <uid>"
  echo "  submit      [-n <node-count>] [-p <project>] [-q <queue>] [-s <script>] [-w <walltime-minutes>]"
}

QCTL_INSTALL=$(dirname $0)
QCTL_HOME=~/.qctl

if [[ $# -lt 1 ]]; then
    echo "USAGE ERROR: too few arguments"
    print_usage
    exit 1
fi

# set reasonable defaults
export QCTL_BATCH_SYSTEM=${QCTL_BATCH_SYSTEM:-none}
export QCTL_COMPUTE_SYSTEM=${QCTL_COMPUTE_SYSTEM:-none}

# load default no-op batch system implementations
cfgfile=batch-systems/default-config.bash
[ -f ${QCTL_INSTALL}/$cfgfile ] && source ${QCTL_INSTALL}/$cfgfile

# load user config
cfgfile=user-config.bash
[ -f ${QCTL_HOME}/$cfgfile ] && source ${QCTL_HOME}/$cfgfile

# load config for current compute system
cfgfile=compute-systems/${QCTL_COMPUTE_SYSTEM}-config.bash
[ -f ${QCTL_INSTALL}/$cfgfile ] && source ${QCTL_INSTALL}/$cfgfile
[ -f ${QCTL_HOME}/$cfgfile ] && source ${QCTL_HOME}/$cfgfile

# load config for current batch system
cfgfile=batch-systems/${QCTL_BATCH_SYSTEM}-config.bash
[ -f ${QCTL_INSTALL}/$cfgfile ] && source ${QCTL_INSTALL}/$cfgfile
[ -f ${QCTL_HOME}/$cfgfile ] && source ${QCTL_HOME}/$cfgfile

action=$1
shift
while [[ $# -gt 0 ]]; do
    opt=$1
    opt_arg=$2
    shift 2 || { echo "USAGE ERROR: missing option $opt argument"; print_usage; exit 1; }
    [[ $opt_arg =~ ^-[[:alpha:]]*$ ]] &&  { echo "USAGE ERROR: missing option $opt argument"; print_usage; exit 1; }
    case $opt in
      "-j")
          export QCTL_JOBID=$opt_arg 
          ;;
      "-n")
          export QCTL_NUM_NODES=$opt_arg 
          ;;
      "-p")
          export QCTL_PROJID=$opt_arg
          ;;
      "-q")
          export QCTL_QUEUE=$opt_arg 
          ;;
      "-s")
          [ -f $opt_arg ] || { echo "ERROR: script file $opt_arg does not exist"; exit 1; }
          export QCTL_JOB_SCRIPT=$opt_arg 
          ;;
      "-u")
          export QCTL_USER=$opt_arg 
          ;;
      "-w")
          export QCTL_WALLTIME=$opt_arg 
          ;;
      *)
          echo "USAGE ERROR: unknown option $opt"
          print_usage
          exit 1
          ;;
    esac
done


if [[ $action == "config" ]]; then
    env | fgrep QCTL_

elif [[ $action == "cancel" ]]; then
    if [[ -n $QCTL_JOBID ]]; then
        eval $(qctl_cancel_job "$QCTL_JOBID")
    elif [[ -n $QCTL_QUEUE ]]; then
        eval $(qctl_cancel_queue "$QCTL_QUEUE" "$QCTL_USER")
    else
        echo "USAGE ERROR: missing cancel option"
        print_usage
        exit 1
    fi

elif [[ $action == "detail" ]]; then
    if [[ -n $QCTL_JOBID ]]; then
        eval $(qctl_detail_job "$QCTL_JOBID")
    elif [[ -n $QCTL_QUEUE ]]; then
        eval $(qctl_detail_queue "$QCTL_QUEUE")
    else
        echo "USAGE ERROR: missing detail option"
        print_usage
        exit 1
    fi

elif [[ $action == "hold" ]]; then
    if [[ -n $QCTL_JOBID ]]; then
        eval $(qctl_hold_job "$QCTL_JOBID")
    elif [[ -n $QCTL_QUEUE ]]; then
        eval $(qctl_hold_queue "$QCTL_QUEUE" "$QCTL_USER")
    else
        echo "USAGE ERROR: missing hold option"
        print_usage
        exit 1
    fi

elif [[ $action == "hosts" ]]; then
    eval $(qctl_status_hosts)

elif [[ $action == "resume" ]]; then
    if [[ -n $QCTL_JOBID ]]; then
        eval $(qctl_resume_job "$QCTL_JOBID")
    elif [[ -n $QCTL_QUEUE ]]; then
        eval $(qctl_resume_queue "$QCTL_QUEUE" "$QCTL_USER")
    else
        echo "USAGE ERROR: missing resume option"
        print_usage
        exit 1
    fi

elif [[ $action == "status" ]]; then
    if [[ -n $QCTL_JOBID ]]; then
        eval $(qctl_status_job "$QCTL_JOBID")
    elif [[ -n $QCTL_PROJID ]]; then
        eval $(qctl_status_project "$QCTL_PROJID" "$QCTL_QUEUE")
    elif [[ -n $QCTL_USER ]]; then
        eval $(qctl_status_user "$QCTL_USER" "$QCTL_QUEUE")
    elif [[ -n $QCTL_QUEUE ]]; then
        eval $(qctl_status_queue "$QCTL_QUEUE")
    else
        echo "USAGE ERROR: missing status option"
        print_usage
        exit 1
    fi

elif [[ $action == "submit" ]]; then
    if [[ -n $QCTL_JOB_SCRIPT ]]; then
        eval $(qctl_submit_batch "$QCTL_QUEUE" "$QCTL_PROJID" "$QCTL_WALLTIME" "$QCTL_NUM_NODES" "$QCTL_JOB_SCRIPT")
    else
        eval $(qctl_submit_interactive "$QCTL_QUEUE" "$QCTL_PROJID" "$QCTL_WALLTIME" "$QCTL_NUM_NODES")
    fi

else
    echo "USAGE ERROR: unknown action $action"
    print_usage
    exit 1
fi

exit 0
