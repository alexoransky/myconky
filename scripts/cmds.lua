cmds = {}

-- conky commands
cmds.rjust = "${alignr}"
cmds.tab40 = "${tab 40}"
cmds.tab50 = "${tab 50}"
cmds.cpu = "${cpu cpuX}"
cmds.freq = "${freq_g}"
cmds.cpubar = "${cpubar cpuX 6, 100}"
cmds.fsbar = "${fs_bar 6, 100 "
cmds.user_number = "${user_number}"
cmds.user_names = "${user_names}"
cmds.loadavg = "${loadavg}"
cmds.uptime = "${uptime}"
cmds.host_name = "${nodename}"
cmds.sys_name = "${sysname}"
cmds.kernel = "${kernel}"


return cmds
