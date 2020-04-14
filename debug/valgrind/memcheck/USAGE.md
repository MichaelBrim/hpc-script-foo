# Valgrind memcheck Helper Scripts

## memcheck-functions.bash

Description:
* Defines utility functions for executing applications under the Valgrind memcheck tool.

USAGE:
* See 'USAGE' comment at the beginning of each function.

## memcheck-wrapper.bash

Description:
* execute a program under Valgrind memory checker tool with full-stack allocation tracking

USAGE:
* `/path/to/memcheck-wrapper.bash <app> [<app-arg> ...]`

FILES: creates one file in current working directory
1. `<app>-<hostname>-<pid>.memcheck-log`- contains stdout/stderr of tool and app

## leakcheck-wrapper.bash

Description:
* execute a program under Valgrind memory checker tool with full leak detection

USAGE:
* `/path/to/leakcheck-wrapper.bash <app> [<app-arg> ...]`

FILES: creates one file in current working directory
1. `<app>-<hostname>-<pid>.leakcheck-log`- contains stdout/stderr of tool and app

