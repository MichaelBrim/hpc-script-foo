# GDB Helper Scripts

## gdb-wrapper.bash

Description:
* execute a program under gdb and capture all thread stacks upon hitting a fault

USAGE:
* `/path/to/gdb-wrapper.bash <app> [<app-arg> ...]`

FILES: creates two files in current working directory
1. `<app>-<hostname>-<pid>.gdb-cmds` - contains gdb batch script
2. `<app>-<hostname>-<pid>.gdb-log`  - contains stdout/stderr of gdb and app
