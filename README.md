# myconky
Conky config and Lua scripts

Conky is an awesome tool to monitor the computer but the config file can be a total mess.
The problem is that conky does not support user variables.  As a result, the same command gets executed several times from the config and multiple if statements become a nightmare.

There is a solution to the problem, though. Conky supports Lua scripting.  In fact, without it
it would be impossible to add growing lists (think "checkupdates" output) to the display.
Other dynamic features, such as alerting on thresholding values would very hard to implement having just the conky commands.

It took me a few days and nights learning Lua and scripting various parts of conky output.
The config file got a lot cleaner and the monitor is capable of much more.
For instance, the list of top 5 processes now displays the heavy hitters based on the total impact, not just the memory or just the CPU. Processes are also grouped by the command name, so it is easy to see what the entire tree of, say, conky, consumes.

Another example is the disk traffic which lets me see the USB drive when it is plugged in and removes the display when there is no USB drive present.

Another nice feature is that I can see all available updates (up to 20), if any.

Performance-wise, scripting did not affect the CPU usage. Without Lua scripting, the total CPU usage was 2.1% for all conky processes (reported by ps -eo).  With Lua scripting, the CPU% went up to 2.2%, a 0.1%, so I am not worrying about it.
