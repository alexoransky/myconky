#!/usr/bin/env lua
--
-- Alex Oransky, 2018
-- https://github.com/alexoransky/myconky
--

--
-- The script outputs a conky command to print the fan speed
--
-- Usage:
--   ${execpi <TIME_PERIOD> <PATH>/mb_fan.lua}:
--   ${execpi 10 ~/.config/conky/scripts/mb_fan.lua}
--
-- Output:
-- Fan   1000 rpm
--

require "./utils/colors"
require "./utils/cmds"
require "./utils/utils"


function get_rpm(s, fan_str)
	local ref = 0
	local temp = ""
    local p1 = 0
    local p2 = 0

	ref = s:find(fan_str)
    if ref == nil then
        return nil
    end

	p1 = s:find(":", ref)
	p2 = s:find("RPM", p1)
	result = utils.ltrim(s:sub(p1+1, p2-1))

    return tonumber(result)
end


function get_fan_rpm(result)
    t = get_rpm(result, "fan1")
    if t == nil then
        return colors.title .. "Fan" .. cmds.rjust .. colors.warning .. "- - -\n"
    end

    local color = colors.normal
    if t < 12 then
    	color = colors.critical
    end

    return colors.title .. "Fan".. cmds.rjust .. color .. tostring(t) .. " rpm\n"
end


local cmd_result = utils.run_command("sensors")
local output = get_fan_rpm(cmd_result)

io.write(output)
