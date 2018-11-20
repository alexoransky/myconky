cmds = {}

-- conky commands
cmds.line = "${hr 2}"
cmds.center = "${alignc}"
cmds.rjust = "${alignr}"
cmds.tab37 = "${tab 37}"
cmds.tab48 = "${tab 48}"
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
cmds.diskio_read = "${diskio_read /dev/sdXY}"
cmds.diskio_write = "${diskio_write /dev/sdXY}"
cmds.diskgr_read = "${diskiograph_read /dev/sdXY 20, 130}"
cmds.diskgr_write = "${diskiograph_write /dev/sdXY 20, 130}"
cmds.addr = "${addr XXX}"

cmds.dn_speed = "${downspeed XXX}"
cmds.up_speed = "${upspeed XXX}"
cmds.dn_total = "${totaldown XXX}"
cmds.up_total = "${totalup XXX}"
cmds.dn_speed_gr = "${downspeedgraph XXX 20, 130 color7 3399FF 10000000 -l -t}"
cmds.up_speed_gr = "${upspeedgraph XXX 20, 130 color7 3399FF 10000000 -l -t}"

return cmds
