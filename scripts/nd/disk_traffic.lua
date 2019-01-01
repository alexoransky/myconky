#!/usr/bin/env lua
--
-- Alex Oransky, 2018
-- https://github.com/alexoransky/myconky
--

--
-- The script outputs a conky command to display the disk traffic from netdata
-- report.
--
-- Usage:
--   ${execpi <TIME_PERIOD> <PATH>/disk_traffic.lua IP}:
--   ${execpi 10 ~/.config/conky/scripts/nd/disk_traffic.lua 192.168.0.100}
--
-- The script requires netdata.
--

require "colors"
require "fonts"
require "cmds"
require "utils"
require "nd"

sysio = "system.io"

IN = 1    -- read
OUT = 2   -- write

function get_dev_traffic(cmd_result)
    local out1 = colors.normal .. fonts.symbols .. "▼  " .. fonts.text
    local out2 = fonts.symbols .. "  ▲" .. fonts.text .. "\n"

    local val = nd.get_values(cmd_result)
    if val == nil then
        return out1 .. colors.warning .. "- - -" .. cmds.rjust .. colors.warning .. "- - -" .. out2
    end

    if #val < OUT then
        return out1 .. colors.warning .. "- - -" .. cmds.rjust .. colors.warning .. "- - -" .. out2
    end

    for i = IN, OUT do
        val[i] = math.abs(val[i]) / 1024    -- translate to Mb/s
        val[i] = utils.round(val[i], 1)
        if val[i] == 0.0 then
            val[i] = "0"
        end
        utils.store_data(i, tonumber(val[i]))
    end

    return out1 .. colors.normal .. val[OUT] .. "M" ..
           cmds.rjust .. colors.normal .. val[IN] .. "M" .. out2 ..
           colors.normal_bar .. cmds.lua_gr:gsub("FN", "load_data_out") ..
           cmds.rjust .. cmds.lua_gr:gsub("FN", "load_data_in") .. "\n"
end


local cmd_result
local output = ""

if arg[1] ~= nil then
    local ip = arg[1]

    local cmd_io = nd.cmd(ip, sysio)

    cmd_result = utils.run_command(cmd_io)
    output = get_dev_traffic(cmd_result)
end

io.write(output)