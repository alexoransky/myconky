#!/usr/bin/env lua
--
-- Alex Oransky, 2018
-- https://github.com/alexoransky/myconky
--

--
-- The script outputs a conky command to print the CPU information of the remote machine:
-- CPU frequency, core temp and the cpu percentage bar.
--
-- Usage:
--   ${execpi <TIME_PERIOD> <PATH>/cpu_info.lua IP}:
--
--   ${execpi 3600 ~/.config/conky/scripts/nd/cpu_info.lua 192.168.0.100}
--
-- Output:
-- 2.74 GHz:   +50°C   5%  [####     ]
--
-- The script requires netdata.

require "colors"
require "cmds"
require "utils"
require "nd"

cpu_temp = "cpu.temperature"
cpu_freq = "cpu.scaling_cur_freq"
cpu_util = "system.cpu"

TEMP_HIGH = 69
TEMP_CRITICAL = 75

function get_freq(cmd_result)
    local v = nd.get_value(cmd_result, 1)
    if v == nil then
        return colors.warning .. "- - -"
    end
    return colors.text .. v .. " GHz"
end


function get_temp(cmd_result)
    local v1 = nd.get_value(cmd_result, 1)
    local v2 = nd.get_value(cmd_result, 2)
    if v1 == nil then
        return colors.warning .. "- - -"
    end
    local t = v1
    if v2 ~= nil then
        t = math.max(v1, v2)
    end

    local color = colors.normal
    if t > TEMP_CRITICAL then
    	color = colors.critical
    elseif t > TEMP_HIGH then
    	color = colors.warning
    end

    return  color .. "+" .. tostring(t) .. "°C"
end


function get_total(cmd_result)
    local vals = nd.get_values(cmd_result)
    if vals == nil then
        return colors.warning .. "- - -"
    end

    perc = 0
    for i = 1, #vals do
        perc = perc + vals[i]
    end
    perc = math.floor(perc + 0.5)

    local color = colors.normal
    local color_bar = colors.normal_bar
    if perc > 90 then
    	color = colors.critical
        color_bar = colors.critical
    elseif perc > 75 then
    	color = colors.warning
        color_bar = colors.warning
    end

    return color .. perc .. "%  " .. color_bar .. cmds.lua_bar:gsub("FN", "echo " .. perc)
end


local cmd_result
local output = ""

if arg[1] ~= nil then
    local ip = arg[1]

    local cmd_freq = nd.cmd(ip, cpu_freq)
    local cmd_temp = nd.cmd(ip, cpu_temp)
    local cmd_util = nd.cmd(ip, cpu_util)

    cmd_result = utils.run_command(cmd_freq)
    output = get_freq(cmd_result)

    cmd_result = utils.run_command(cmd_temp)
    output = output .. cmds.tab40 .. get_temp(cmd_result)

    cmd_result = utils.run_command(cmd_util)
    output = output .. cmds.rjust .. get_total(cmd_result) .. "\n"
end

io.write(output)
