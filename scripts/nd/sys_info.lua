#!/usr/bin/env lua
--
-- Alex Oransky, 2018
-- https://github.com/alexoransky/myconky
--

--
-- The script outputs a conky command to print the uptime and load information of
-- of the remote machine.
--
--
-- Usage:
--   ${execpi <TIME_PERIOD> <PATH>/sys_info.lua IP}:
--   ${execpi 3600 ~/.config/conky/scripts/nd/sys_info.lua 192.168.0.100}
--
-- The script requires netdata.
--

require "colors"
require "cmds"
require "utils"
require "nd"

uptime = "system.uptime"
load = "system.load"


function get_uptime(cmd_result)
    local result = colors.title .. "Uptime" .. cmds.rjust

    v = nd.get_value(cmd_result, 1)
    if v == nil then
        return result .. colors.warning .. "- - -"
    end

    return result .. colors.text .. utils.sec_to_human(v)
end

function get_load(cmd_result)
    local output = colors.title .. "Load" .. cmds.rjust

    local vals = nd.get_values(cmd_result)
    for i = 1, #vals do
        color = colors.normal
        if vals[i] > 5.0 then
            color = colors.critical
        elseif vals[i] > 1.0 then
            color = colors.warning
        end
        output = output .. " " .. color .. tostring(string.format("%.2f", vals[i]))
    end

    return output
end


local cmd_result
local output = ""

if arg[1] ~= nil then
    local ip = arg[1]

    local cmd_uptime = nd.cmd(ip, uptime)
    local cmd_load = nd.cmd(ip, load)

    cmd_result = utils.run_command(cmd_uptime)
    output = get_uptime(cmd_result) .. "\n"

    cmd_result = utils.run_command(cmd_load)
    output = output .. get_load(cmd_result) .. "\n"
end

io.write(output)
