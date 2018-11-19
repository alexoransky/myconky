#!/usr/bin/env lua

--
-- The script outputs a conky command to print the uptime.
--
--
-- Usage:
--   ${execi<PATH>/uptime.lua}:
--   ${execi ~/.config/conky/scripts/uptime.lua}
--
-- Output:
-- Uptime   22h 33m 44s
--
-- This script implements the conky command below.
-- ${color2}Uptime ${alignr}${color1} $uptime
--

require "colors"
require "cmds"
require "utils"


function get_uptime()
    return colors.title .. "Uptime " .. cmds.rjust .. colors.text .. cmds.uptime .. "\n"
end


local output = get_uptime()
io.write(output)
