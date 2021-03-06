#!/usr/bin/env lua
--
-- Alex Oransky, 2018
-- https://github.com/alexoransky/myconky
--

--
-- The script outputs a conky command to print the HDD temp
--
-- Usage:
--   ${execpi <TIME_PERIOD> <PATH>/hdd_temp.lua <DISK>}:
--   ${execpi 10 ~/.config/conky/scripts/hdd_temp.lua /dev/sda}
--
-- Output:
-- Disk Temp   +25.0°C
--

require "./utils/colors"
require "./utils/cmds"
require "./utils/utils"

TEMP_HIGH = 65
TEMP_CRITICAL = 80

function get_temp(s, temp_str)
	local ref = 0
	local temp = ""
    local p1 = 0
    local p2 = 0

	ref = s:find(temp_str)
    if ref == nil then
        return nil
    end

	p1 = s:find(": ", ref+1)
	p2 = s:find("C", p1)
	temp = s:sub(p1+2, p2-3)

	return tonumber(temp)
end


function get_hdd_temp(result)
    t = get_temp(result, ": ")
    if t == nil then
        return colors.title .. "Disk Temp" .. cmds.rjust .. colors.warning .. "- - -\n"
    end

    local color, cb = colors.define(t, TEMP_HIGH, TEMP_CRITICAL)

    return colors.title .. "Disk Temp".. cmds.rjust .. color .. " +" .. tostring(t) .. "°C" .. "\n"
end

local cmd_result = utils.run_command("hddtemp " .. arg[1])
local output = get_hdd_temp(cmd_result)
io.write(output)
