# SSH Helper Scripts

## check-ssh.bash, check-ssh-all-hosts.bash

Description:
* `check-ssh-all-hosts.bash` - verifies ssh without password works between all pairs of hosts from given hostfile
* `check-ssh.bash` - verifies ssh without password works between current host and all hosts in given hostfile

USAGE:
* `/path/to/check-ssh-all-hosts.bash <hostfile>`
* `/path/to/check-ssh.bash <hostfile>`

FILES:
1. <hostfile> - should contain hostnames separated by spaces/newlines
