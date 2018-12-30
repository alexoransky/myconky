# Myconky

Conky is an awesome tool to monitor the computer but the config file can be a total mess.
The problem is that Conky does not support user variables, nor does it provide loops. As a result, the same command gets executed several times from the config and multiple if statements are a nightmare.

There is a solution to the problem, though. Conky supports Lua scripting. It really helps! In fact, without Lua scripting it would be impossible to add growing lists (think "checkupdates" output) to the display. Other dynamic features, such as alerting on thresholding values would be very hard to implement with having just Conky commands.

It took me a few days and nights learning Lua and writing scripts for various parts of Conky output.
As a result, the config file got a lot cleaner. What used to take ten lines now takes one.

The monitor is capable of much more now, too. For instance, the list of top 5 processes now displays the heavy hitters based on the total impact, not just the memory or just the CPU usage. Processes are also grouped by the command name, so it is easy to see what the entire tree of, say, Conky processes consumes.

Another improvement is the monitor for the disk traffic which lets me see the USB drive when it is plugged in and removes the display when there is no USB drive.

Another nice feature is the list of all (well, up to 20) available updates in the bottom of the window.

## Features

### Extremely clean config files
Myconky was created to remove clutter from the config file as much as possible.  A single _short_ config line creates multi-line output with text, bars, graphs and dynamically changed colors. There is no need to have nested IF statements in the config anymore. Also, there is no need to work around non-existing loops or variables in the config file.

### Alerting on thresholding values
Myconky provides for "normal", "warning" and "critical" alerts by using different colors.  Nearly every parameter is monitored that way. Even better, Myconky eleiominates the need to remember the meaning of "$color1" and so on.

### Dynamic multi-line display
Myconky outputs only the necessary number of lines in lists and avoids creating empty entries. A typical example is a list of available updates. Myconky will display only the right number of updates or nothing.  Another example is a write/read graphs for a USB disk. Myconky hides those competely untill the USB drive is mounted.

### Monitoring of the local system
Myconky supports almost all "native" Conky commands but makes them much easier to use. There is no need to remember syntax of each command anymore. All commands are collected in a single Lua file and take parameters.

Myconky also support parsing of many shell commands, including ping, curl, ps and so on. This extends the basic Conky command set tremendously. For instance, backups to a remote machine can be monitored with ease.

### Monitoring of remote systems
Myconky also supports monitoring of remote systems by the use of netdata. As long as netdata package is installed on the remote machine, Myconky will display system uptime, load, CPU utilization, available RAM and much more for that machine.

## Dependencies

1. Conky 1.10.x
2. Lua CJSON
3. Shell commands
4. netdata

### Conky 1.10.8 and 1.11
As of now, the config file is not compatible with Conky 1.11.1. I had to revert back to Conky 1.10.8-2.

### Lua CJSON
[Lua CJSON](https://github.com/mpx/lua-cjson/) is an extremely fast JSON library for Lua scripting. It is compatible with Lua 5.3. To install, follow the [manual](https://www.kyne.com.au/~mark/software/lua-cjson-manual.html). You will need to change the Makefile to target Lua 5.3 and then copy the .so file to the Lua lib folder.

### Shell Commands
Myconky scripts use various CLI commands (ping, ps, avahi-resolve, urbackupclientctl etc.) to obtain the necessary information, parse the command output and create commands that are fed to Conky. Follow instructions for your system poackage manager to install them.

### netdata
A subset of scripts is dedicated to parsing of netdata output.  This allows for monitoring of remote machines, for example, a NAS. The remote machine must have [netdata](https://my-netdata.io) installed.

## Performace
Performance-wise, scripting did not affect the CPU usage much. Without Lua scripting, the total CPU usage was 2.1% for all Conky processes (reported by "ps -eo").  With Lua scripting, the CPU% went up to 2.2%, only 0.1%, so I am not worrying.
