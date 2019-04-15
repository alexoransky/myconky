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

function get_disp_val(val)
    dv = val
    unit = "K"

    if dv >= 1023.5 then
        dv = dv / 1024
        unit = "M"
    end

    dv = utils.round(dv, 1)

    return dv .. unit
end

function get_net_traffic(cmd_result, infc, ip)
    local out1 = colors.normal .. fonts.symbols .. "▼  " .. fonts.text
    local out2 = colors.normal .. fonts.symbols .. "  ▲" .. fonts.text

    local outc = ""
    if infc ~= nil then
        outc = cmds.center .. colors.title .. "                " .. infc
    end

    local p1 = utils.rfind(ip, "%.")
    local p2 = utils.rfind(ip, ":")
    local last_num = ip:sub(p1+1, p2)

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
        val[i] = val[i] / 8 -- convert from kilobit/s to kilobyte/s
        utils.store_data(i - RECEIVED + 1, tonumber(val[i]), utils.xfer_path_network..last_num)  -- indexing is 1-based
    end

    local recv = get_disp_val(val[RECEIVED])
    local sent = get_disp_val(val[SENT])

    return out1 .. colors.normal .. recv .. outc ..
           cmds.rjust .. colors.normal .. sent .. out2 .. "\n" ..
           colors.normal_bar .. cmds.lua_gr:gsub("FN", "load_data_received_"..last_num) ..
           cmds.rjust .. cmds.lua_gr:gsub("FN", "load_data_sent_"..last_num) .. "\n"
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
    output = get_net_traffic(cmd_result, arg[2], ip)
end


io.write(output)
