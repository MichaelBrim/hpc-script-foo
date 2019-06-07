# Universal Batch Queue Control

## qctl

Description:
* use same commands to interact with various queueing systems

Usage:
```
export QCTL_BATCH_SYSTEM="lsf" # or "pbs", "slurm"

qctl <action> [<action-options>]

  Actions     Options
--------------------------------------------
  config      N/A
  cancel      -j <jobid> | -q <queue>
  detail      -j <jobid> | -q <queue>
  hold        -j <jobid> | -q <queue>
  hosts       N/A
  resume      -j <jobid> | -q <queue>
  status      -j <jobid> | -p <project> | -q <queue> | -u <uid>
  submit      [-n <node-count>] [-p <project>] [-q <queue>] [-s <script>] [-w <walltime-minutes>]
```

