#!/usr/bin/env lua
--
-- Alex Oransky, 2018
-- https://github.com/alexoransky/myconky
--

--
-- The script outputs a conky command to print the imformation for the
-- installed CPU.
--
-- Usage:
--   ${execpi <TIME_PERIOD> <PATH>/cpu_model.lua [-s]}:
--   -s will print CPU speed
--   ${execpi 3600 ~/.config/conky/scripts/cpu_model.lua}
--
-- Output:
-- CPU  Intel(R) Core(TM) i7-4785T
--
-- This script implements the conky command below.
--
-- ${color2}CPU ${alignr}${color1}\
-- ${execi 3600 cat /proc/cpuinfo | grep 'model name' | sed -e 's/model name.*: //'| uniq}
--

require "./utils/colors"
require "./utils/cmds"
require "./utils/utils"


function get_cpu_info(fpath, item, return_speed)
    -- parses the /proc/cpuinfo for the cpu model name
    -- input
    --   fpath = path to "/proc/cpuinfo" or other file
    --   item = "cpu_model" or parameter to find
    --   return_speed: true or false
    -- returns:
    --   model name

    -- find the cpu model
    local ref = 0
	local temp = utils.read_from_file(fpath, item)
    if temp ~= nil then
        ref = temp:find(":")
    end

    if temp == nil or ref == nil then
        return colors.title .. "CPU " .. cmds.rjust .. "  - - -\n"
    end

    local sp = 0
    local output = temp:sub(ref+2)
    if not return_speed then
        sp = temp:find("CPU @", ref)
        if sp ~= nil then
            output = temp:sub(ref+2, sp-2)
        end
    end

    return colors.title .. "CPU " .. cmds.rjust .. colors.text .. output .. "\n"
end

local output = get_cpu_info("/proc/cpuinfo", "model name", (arg[1] == "-s"))
io.write(output)
