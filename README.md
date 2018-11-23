# myconky
A set of Lua scripts to make the config clean and simple

Conky is an awesome tool to monitor the computer but the config file can be a total mess.
The problem is that conky does not support user variables, nor does it provide loops. As a result, the same command gets executed several times from the config and multiple if statements are a nightmare.

There is a solution to the problem, though. Conky supports Lua scripting. It really helps! In fact, without Lua scripting it would be impossible to add growing lists (think "checkupdates" output) to the display. Other dynamic features, such as alerting on thresholding values would be very hard to implement with having just conky commands.

It took me a few days and nights learning Lua and writing scripts for various parts of conky output.
As a result, the config file got a lot cleaner. What used to take ten lines now takes one.

The monitor is capable of much more now, too. For instance, the list of top 5 processes now displays the heavy hitters based on the total impact, not just the memory or just the CPU usage. Processes are also grouped by the command name, so it is easy to see what the entire tree of, say, conky processes consumes.

Another improvement is the monitor for the disk traffic which lets me see the USB drive when it is plugged in and removes the display when there is no USB drive.

Another nice feature is the list of all (well, up to 20) available updates in the bottom of the window.

Performance-wise, scripting did not affect the CPU usage much. Without Lua scripting, the total CPU usage was 2.1% for all conky processes (reported by "ps -eo").  With Lua scripting, the CPU% went up to 2.2%, only 0.1%, so I am not worrying.
