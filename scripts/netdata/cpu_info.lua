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
--   ${execpi 3600 ~/.config/conky/scripts/nd/cpu_info.lua 192.168.0.100:19999}
--
-- Output:
-- 2.74 GHz:   +50°C   5%  [####     ]
--
-- The script requires netdata.

require "colors"
require "cmds"
require "utils"
require "nd"

-- temp through the old bash script:
sensors_temp = "sensors.temp_thermal_zone0_thermal_thermal_zone0"
-- temp through the new python module:
cpu_temp = "cpu.temperature"
cpu_freq = "cpu.scaling_cur_freq"
cpu_freq2 = "cpu.cpufreq"
cpu_util = "system.cpu"

TEMP_HIGH = 69
TEMP_CRITICAL = 75

FREQUENCY = 2
CPU0 = 2
CPU1 = 3

function get_freq(cmd_result1, cmd_result2)
    local v1 = nd.get_value(cmd_result1, FREQUENCY)
    if v1 ~= nil then
        return colors.text .. v1 .. " GHz"
    end

    local v2 = nd.get_value(cmd_result2, FREQUENCY)
    if v2 ~= nil then
        v2 = utils.round(v2/1000, 1)
        return colors.text .. v2 .. " GHz"
    end

    return colors.warning .. "- - - " .. " GHz"
end


function get_temp(cmd_result)
    local v1 = nd.get_value(cmd_result, CPU0)
    local v2 = nd.get_value(cmd_result, CPU1)
    if v1 == nil then
        return colors.warning .. " - - - " .. "°C"
    end
    local t = v1
    if v2 ~= nil then
        t = math.max(v1, v2)
    end
    t = utils.round(t, 1)

    local color, cb = colors.define(t, TEMP_HIGH, TEMP_CRITICAL)

    return  color .. "+" .. tostring(t) .. "°C"
end


function get_total(cmd_result)
    local vals = nd.get_values(cmd_result)
    if vals == nil then
        return ""
    end

    local perc = 0
    -- timestamp is #1, so start iterating from #2
    for i = 2, #vals do
        perc = perc + vals[i]
    end
    perc = utils.round(perc, 1)

    local color, color_bar = colors.define(perc)

    return color .. perc .. "%  " .. color_bar .. cmds.lua_bar:gsub("FN", "echo " .. perc)
end


local cmd_result
local output = ""

if arg[1] ~= nil then
    local ip = arg[1]
    local temp_group = cpu_temp
    if arg[2] == "-s" then
        temp_group = sensors_temp
    end

    local cmd_freq = nd.cmd(ip, cpu_freq)
    local cmd_freq2 = nd.cmd(ip, cpu_freq2)
    local cmd_temp = nd.cmd(ip, temp_group)
    local cmd_util = nd.cmd(ip, cpu_util)

    cmd_result = utils.run_command(cmd_freq)
    cmd_result2 = utils.run_command(cmd_freq2)
    output = colors.title .. "CPU  " .. get_freq(cmd_result, cmd_result2)

    cmd_result = utils.run_command(cmd_temp)
    output = output .. cmds.tab(40) .. get_temp(cmd_result)

    cmd_result = utils.run_command(cmd_util)
    output = output .. cmds.rjust .. get_total(cmd_result) .. "\n"
end

io.write(output)
