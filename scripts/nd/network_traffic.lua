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
interface = "net."

RECEIVED = 2
SENT = 3

function get_net_traffic(cmd_result, infc)
    local out1 = colors.normal .. fonts.symbols .. "▼  " .. fonts.text
    local out2 = colors.normal .. fonts.symbols .. "  ▲" .. fonts.text

    local outc = ""
    if infc ~= nil then
        outc = cmds.center .. colors.title .. "                " .. infc
    end

    local val = nd.get_values(cmd_result)
    if val == nil or #val < SENT then
        return out1 .. colors.warning .. "- - -" .. outc .. cmds.rjust .. colors.warning .. "- - -" .. out2
    end

    for i = RECEIVED, SENT do
        val[i] = math.abs(val[i])
        val[i] = utils.round(val[i], 1)
        if val[i] == 0.0 then
            val[i] = 0
        end
        utils.store_data(i - RECEIVED + 1, tonumber(val[i]), utils.xfer_path_network)  -- indexing is 1-based
    end

    recv = val[RECEIVED] .. "K"
    sent = val[SENT] .. "K"
    if val[RECEIVED] > 1024 then
        recv = utils.round(val[RECEIVED] / 1024, 1) .. "M"
    end
    if val[SENT] > 1024 then
        sent = utils.round(val[SENT] / 1024, 1) .. "M"
    end

    return out1 .. colors.normal .. recv .. outc ..
           cmds.rjust .. colors.normal .. sent .. out2 .. "\n" ..
           colors.normal_bar .. cmds.lua_gr:gsub("FN", "load_data_received") ..
           cmds.rjust .. cmds.lua_gr:gsub("FN", "load_data_sent") .. "\n"
end


local cmd_result
local output = ""

if arg[1] ~= nil then
    local ip = arg[1]

    local cmd = sysio
    if arg[2] ~= nil then
        cmd = interface .. arg[2]
    end

    local cmd_io = nd.cmd(ip, cmd)
    cmd_result = utils.run_command(cmd_io)
    output = get_net_traffic(cmd_result, arg[2])
end


io.write(output)
