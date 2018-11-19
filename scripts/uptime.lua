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

require 'colors'

-- conky commands
rjust = "${alignr}"
uptime = "${uptime}"


function get_uptime()
    return colors.title .. "Uptime " .. rjust .. colors.text .. uptime .. "\n"
end


local output = get_uptime()
io.write(output)
