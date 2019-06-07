#!/bin/bash

print_usage () {
  echo "$0 <action> [<action-options>]"
  echo
  echo "  Actions     Options"
  echo "--------------------------------------------"
  echo "  config      N/A"
  echo "  cancel      -j <jobid>, -p <project>, -q <queue>, -u <uid>"
  echo "  hold        -j <jobid>, -p <project>, -q <queue>, -u <uid>"
  echo "  resume      -j <jobid>, -p <project>, -q <queue>, -u <uid>"
  echo "  status      -j <jobid>, -p <project>, -q <queue>, -u <uid>"
  echo "  submit      -n <node-count>, -p <project>, -q <queue>, -s <script>, -w <walltime-minutes>"
}


if [[ $# -lt 1 ]]; then
    echo "USAGE ERROR: too few arguments"
    print_usage
    exit 1
fi

# set reasonable defaults
export QCTL_BATCH_SYSTEM=${QCTL_BATCH_SYSTEM:-none}
export QCTL_COMPUTE_SYSTEM=${QCTL_COMPUTE_SYSTEM:-$NCCS_SYSTEM}
export QCTL_PROJECT=${QCTL_PROJECT:-$NCCS_PROJECT}
export QCTL_USER=${QCTL_USER:-$NCCS_USER}

# load default batch system implementations
cfgfile=batch-systems/default-config.bash
[ -f $cfgfile ] && source $cfgfile

# load user config
cfgfile=${HOME}/.qctl-config
[ -f $cfgfile ] && source $cfgfile

# load config for current project
cfgfile=projects/${QCTL_PROJECT}-config.bash
[ -f $cfgfile ] && source $cfgfile

# load config for current compute system
cfgfile=compute-systems/${QCTL_COMPUTE_SYSTEM}-config.bash
[ -f $cfgfile ] && source $cfgfile

# load config for current batch system
cfgfile=batch-systems/${QCTL_BATCH_SYSTEM}-config.bash
[ -f $cfgfile ] && source $cfgfile

action=$1
shift
while [[ $# -gt 0 ]]; do
    opt=$1
    opt_arg=$2
    shift 2 || { echo "USAGE ERROR: missing option $opt argument"; print_usage; exit 1; }
    [[ $opt_arg =~ -[[:alpha:]] ]] &&  { echo "USAGE ERROR: missing option $opt argument"; print_usage; exit 1; }
    case $opt in
      "-j")
          export QCTL_JOBID=$opt_arg 
          ;;
      "-n")
          export QCTL_NUM_NODES=$opt_arg 
          ;;
      "-p")
          export QCTL_PROJECT=$opt_arg 
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
    echo $(qctl_cancel_job "$QCTL_QUEUE" "$QCTL_JOBID")
    echo $(qctl_cancel_queue "$QCTL_QUEUE")

elif [[ $action == "hold" ]]; then
    echo $(qctl_hold_job "$QCTL_QUEUE" "$QCTL_JOBID")
    echo $(qctl_hold_queue "$QCTL_QUEUE")

elif [[ $action == "resume" ]]; then
    echo $(qctl_resume_job "$QCTL_QUEUE" "$QCTL_JOBID")
    echo $(qctl_resume_queue "$QCTL_QUEUE")

elif [[ $action == "status" ]]; then
    echo $(qctl_detail_job "$QCTL_QUEUE" "$QCTL_JOBID")
    echo $(qctl_detail_queue "$QCTL_QUEUE")
    echo $(qctl_status_hosts)
    echo $(qctl_status_job "$QCTL_QUEUE" "$QCTL_JOBID")
    echo $(qctl_status_queue "$QCTL_QUEUE")
    echo $(qctl_status_user "$QCTL_QUEUE" "$QCTL_USER")

elif [[ $action == "submit" ]]; then
    echo $(qctl_submit_batch "$QCTL_QUEUE" "$QCTL_PROJECT" "$QCTL_WALLTIME" "$QCTL_NUM_NODES" "$QCTL_JOB_SCRIPT")
    echo $(qctl_submit_interactive "$QCTL_QUEUE" "$QCTL_PROJECT" "$QCTL_WALLTIME" "$QCTL_NUM_NODES")

else
    echo "USAGE ERROR: unknown action $action"
    print_usage
    exit 1
fi

exit 0
