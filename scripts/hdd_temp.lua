#!/usr/bin/env lua

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

require "colors"
require "cmds"
require "utils"


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

    local color = colors.normal
    if t > 80.0 then
    	color = colors.critical
    elseif t > 65.0 then
    	color = colors.warning
    end

    return output = colors.title .. "Disk Temp".. cmds.rjust .. color .. " +" .. tostring(t) .. "°C" .. "\n"
end

local cmd_result = utils.run_command("hddtemp " .. arg[1])
local output = get_hdd_temp(cmd_result)
io.write(output)
