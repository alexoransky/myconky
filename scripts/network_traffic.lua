#!/usr/bin/env lua

--
-- The script outputs a conky command to display the network traffic.
--
-- Usage:
--   ${execpi <TIME_PERIOD> <PATH>/network_traffic.lua <interface> [<interface> ...]}:
--   e.g. for eno1 and wlan0:
--   ${execp ~/.config/conky/scripts/network_traffic.lua eno1 wlan0}
--

require "colors"
require "fonts"
require "cmds"
require "utils"


function get_traffic(infc)
    local output = colors.normal .. fonts.symbols .. "▼  " .. fonts.text ..
                   cmds.dn_speed:gsub("XXX", infc) .. cmds.tab48 .. cmds.dn_total:gsub("XXX", infc) ..
                   cmds.tab37..
                   cmds.up_speed:gsub("XXX", infc) .. cmds.rjust .. cmds.up_total:gsub("XXX", infc) ..
                   fonts.symbols .. "  ▲" .. fonts.text .. "\n" ..
                   colors.normal_bar .. cmds.dn_speed_gr:gsub("XXX", infc) ..
                   cmds.rjust .. cmds.up_speed_gr:gsub("XXX", infc) .. "\n"
    return output
end


local output = ""
local result = ""

for i = 1, #arg do
    result = get_traffic(arg[i])
    output = output .. result
end

io.write(output)
