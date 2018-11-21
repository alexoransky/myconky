cmds = {}

-- conky commands
cmds.line = "${hr 2}"
cmds.center = "${alignc}"
cmds.rjust = "${alignr}"
cmds.tab37 = "${tab 37}"
cmds.tab48 = "${tab 48}"
cmds.tab40 = "${tab 40}"
cmds.tab50 = "${tab 50}"
-- information
cmds.cpu = "${cpu cpuX}"
cmds.freq = "${freq_g}"
cmds.user_number = "${user_number}"
cmds.user_names = "${user_names}"
cmds.loadavg = "${loadavg}"
cmds.uptime = "${uptime}"
cmds.utc = "${utime}"
cmds.host_name = "${nodename}"
cmds.sys_name = "${sysname}"
cmds.kernel = "${kernel}"
cmds.diskio_read = "${diskio_read /dev/sdXY}"
cmds.diskio_write = "${diskio_write /dev/sdXY}"
-- processes
cmds.top_name = "${top name X}"
cmds.top_pid = "${top pid X}"
cmds.top_cpu = "${top cpu X}"
cmds.top_mem = "${top mem X}"
-- network
cmds.addr = "${addr XXX}"
cmds.dn_speed = "${downspeed XXX}"
cmds.up_speed = "${upspeed XXX}"
cmds.dn_total = "${totaldown XXX}"
cmds.up_total = "${totalup XXX}"
-- bars
cmds.cpu_bar = "${cpubar cpuX 6, 100}"
-- TODO: fix the command
cmds.fs_bar = "${fs_bar 6, 100 "
-- graphs
cmds.disk_read_gr = "${diskiograph_read /dev/sdXY 20, 130}"
cmds.disk_write_gr = "${diskiograph_write /dev/sdXY 20, 130}"
cmds.dn_speed_gr = "${downspeedgraph XXX 20, 130 color7 3399FF 10000000 -l -t}"
cmds.up_speed_gr = "${upspeedgraph XXX 20, 130 color7 3399FF 10000000 -l -t}"
cmds.cpu_gr = "${cpugraph 20,278 color7 ff0000 -t}"
-- weather
cmds.metar_templ = "${weather SRC ICAO INFO}"
cmds.metar_src = "http://tgftp.nws.noaa.gov/data/observations/metar/stations/"
cmds.metar_template = cmds.metar_templ:gsub("SRC", cmds.metar_src)
cmds.metar_time = cmds.metar_template:gsub("INFO", "last_update")
cmds.metar_cloud_cover = cmds.metar_template:gsub("INFO", "cloud_cover")
cmds.metar_weather = cmds.metar_template:gsub("INFO", "weather")
cmds.metar_temperature = cmds.metar_template:gsub("INFO", "temperature")
cmds.metar_pressure = cmds.metar_template:gsub("INFO", "pressure")
cmds.metar_humidity = cmds.metar_template:gsub("INFO", "humidity")
cmds.metar_wind_dir = cmds.metar_template:gsub("INFO", "wind_dir")
cmds.metar_wind_speed = cmds.metar_template:gsub("INFO", "wind_speed")

return cmds
