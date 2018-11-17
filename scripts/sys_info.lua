#!/usr/bin/env lua

--
-- The script outputs a conky command to print the host name, system and kernel.
--
--
-- Usage:
--   ${execpi <TIME_PERIOD> <PATH>/sys_info.lua}:
--   ${execpi 3600 ~/.config/conky/scripts/sys_info.lua}
--
-- Output:
-- arch   Linux 4.19.1-arch1-1-ARCH
--
-- This script implements the conky command below.
-- ${color1}${nodename}${alignr}${sysname} ${kernel}
--

-- conky colors
--local colors = require("colors")
colors = {}
colors.title = "${color2}"
colors.text  = "${color1}"
colors.normal = "${color6}"
colors.normal_bar = "${color4}"
colors.warning = "${color8}"
colors.critical = "${color9}"

-- conky commands
rjust = "${alignr}"
host_name = "${nodename}"
sys_name = "${sysname}"
kernel = "${kernel}"


function get_sys_info()
    return colors.text .. host_name .. rjust .. sys_name .. " " .. kernel .. "\n"
end


local output = get_sys_info()
io.write(output)
