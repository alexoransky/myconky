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
--   ${execpi <TIME_PERIOD> <PATH>/network_traffic.lua IP}:
--   ${execpi 10 ~/.config/conky/scripts/nd/network_traffic.lua 192.168.0.100}
--
-- The script requires netdata.
--

require "colors"
require "fonts"
require "cmds"
require "utils"
require "nd"

sysio = "system.ipv4"

RECEIVED = 2
SENT = 3

function get_net_traffic(cmd_result)
    local out1 = colors.normal .. fonts.symbols .. "▼  " .. fonts.text
    local out2 = colors.normal .. fonts.symbols .. "  ▲" .. fonts.text

    local val = nd.get_values(cmd_result)
    if val == nil or #val < SENT then
        return out1 .. colors.warning .. "- - -" .. cmds.rjust .. colors.warning .. "- - -" .. out2
    end

    for i = RECEIVED, SENT do
        val[i] = math.abs(val[i])
        val[i] = utils.round(val[i], 1)
        if val[i] == 0.0 then
            val[i] = "0"
        end
        utils.store_data(i - RECEIVED + 1, tonumber(val[i]), utils.xfer_path_network)  -- indexing is 1-based
    end

    return out1 .. colors.normal .. val[RECEIVED] .. "K" ..
           cmds.rjust .. colors.normal .. val[SENT] .. "K" .. out2 .. "\n" ..
           colors.normal_bar .. cmds.lua_gr:gsub("FN", "load_data_received") ..
           cmds.rjust .. cmds.lua_gr:gsub("FN", "load_data_sent") .. "\n"
end


local cmd_result
local output = ""

if arg[1] ~= nil then
    local ip = arg[1]
    local cmd_io = nd.cmd(ip, sysio)
    cmd_result = utils.run_command(cmd_io)
    output = get_net_traffic(cmd_result)
end


io.write(output)
