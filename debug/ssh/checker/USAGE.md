# SSH Helper Scripts

## check_ssh.bash, check_ssh_all_hosts.bash

Description:
* `check_ssh_all_hosts.bash` - verifies ssh without password works between all pairs of hosts from given hostfile
* `check_ssh.bash` - verifies ssh without password works between current host and all hosts in given hostfile

USAGE:
* `/path/to/check_ssh_all_hosts.bash <hostfile>`
* `/path/to/check_ssh.bash <hostfile>`

FILES:
1. `<hostfile>` - should contain hostnames separated by spaces/newlines
