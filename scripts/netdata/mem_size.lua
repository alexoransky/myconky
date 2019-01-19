#!/usr/bin/env lua
--
-- Alex Oransky, 2018
-- https://github.com/alexoransky/myconky
--

--
-- The script outputs a conky command to print the RAM information of the remote machine:
-- total RAM, RAM utilization and the RAM percentage bar.
--
-- Usage:
--   ${execpi <TIME_PERIOD> <PATH>/mem_size.lua IP}:
--
--   ${execpi 3600 ~/.config/conky/scripts/nd/mem_size.lua 192.168.0.100}
--
-- Output:
-- RAM      5%  [####     ]
--
-- The script requires netdata.

require "colors"
require "cmds"
require "utils"
require "nd"

ram_util = "system.ram"
swap_util = "system.swap"

FREE = 2      -- both in RAM and Swap
INACTIVE = 4  -- RAM only

function get_mem_vals(vals)
    local total = 0
    -- timestamp is #1, so start iterating from #2
    for i = 2, #vals do
        total = total + vals[i]
    end
    total = utils.round(total, 1)  -- value in Mb

    -- claculate free RAM as a sum of "free" and "inactive"
    -- Swap will not have "inactive" component
    local free = 0
    local used = total
    local perc = 100
    if #vals >= FREE then
        free = free + vals[FREE]
    end
    if #vals >= INACTIVE then
        free = free + vals[INACTIVE]
    end
    used = total - free

    if total > 0 then
        perc = utils.round(used * 100 / total, 1)
    end

    return total, perc
end

function get_info(ram_result, swap_result)
    local vals = nd.get_values(ram_result)
    if vals == nil then
        return colors.title .. "RAM  " .. cmds.rjust .. colors.warning .. "- - -"
    end

    local mem_total, mem_perc = get_mem_vals(vals)
    mem_total = utils.round(mem_total / 1024, 1)  -- convert to Gb

    local color, color_bar = colors.define(mem_perc)
	local output = colors.title .. "RAM   " .. cmds.tab(40) .. colors.text ..
                   mem_total .. " G".. cmds.rjust .. color .. mem_perc ..
                   "%  " .. color_bar .. cmds.lua_bar:gsub("FN", "echo " .. mem_perc)

   vals = nd.get_values(swap_result)
   if vals == nil then
       return output
   end

   local swap_total, swap_perc = get_mem_vals(vals)
   swap_total = utils.round(swap_total / 1024, 1)  -- convert to Gb

    if swap_perc < 1 and mem_perc <= 75 then
        return output
    end

    color, color_bar = colors.define(swap_perc)

    output = output .. "\n" .. colors.title .. "SWAP " .. cmds.tab(40) ..
             colors.text .. swap_total .. " G".. cmds.rjust .. color ..
             swap_perc .. "%  " .. color_bar .. cmds.lua_bar:gsub("FN", "echo " .. swap_perc)

    return output
end

local output = ""
if arg[1] ~= nil then
    local ip = arg[1]

    local cmd_ram = nd.cmd(ip, ram_util)
    local cmd_swap = nd.cmd(ip, swap_util)

    local ram_result = utils.run_command(cmd_ram)
    local swap_result = utils.run_command(cmd_swap)
    output = get_info(ram_result, swap_result) .. "\n"
end

io.write(output)
