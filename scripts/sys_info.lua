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

require "colors"
require "cmds"
require "utils"


function get_sys_info()
    return colors.text .. cmds.host_name .. cmds.rjust .. cmds.sys_name .. " " .. cmds.kernel .. "\n"
end


local output = get_sys_info()
io.write(output)
