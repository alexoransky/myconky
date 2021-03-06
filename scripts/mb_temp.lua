#!/usr/bin/env lua
--
-- Alex Oransky, 2018
-- https://github.com/alexoransky/myconky
--

--
-- The script outputs a conky command to print the motherboard temp
--
-- Usage:
--   ${execpi <TIME_PERIOD> <PATH>/mb_temp.lua}:
--   ${execpi 10 ~/.config/conky/scripts/mb_temp.lua}
--
-- Output:
-- Temp   +25°C
--
-- This script implements the conky command below .
-- The script indicates percentage used with color and if there is no
-- specified device, it outputs dashes.
--
-- ${color2}Temp ${color6}${alignr}\
-- ${execi 10 sensors | grep 'temp2' | awk {'print $2'}}
--
-- The script needs lm-sensors and/or acpi packets installed.

require "./utils/colors"
require "./utils/cmds"
require "./utils/utils"

TEMP_HIGH = 65
TEMP_CRITICAL = 80

function get_sensors_temp(s, temp_str)
	local ref = 0
	local temp = ""
    local p1 = 0
    local p2 = 0

	ref = s:find(temp_str)
    if ref == nil then
        return nil
    end

	p1 = s:find("+", ref+1)
	p2 = s:find("C", p1)
	temp = s:sub(p1, p2-5)

	return tonumber(temp)
end


function get_acpi_temp(s, temp_str)
	local ref = 0
	local temp = ""
    local p1 = 0
    local p2 = 0

	ref = s:find(temp_str)
    if ref == nil then
        return nil
    end

    local str = s:sub(ref)
    local words = utils.split_str(str)
    local temp = tonumber(words[4]:sub(1, 5))

	return temp
end


function get_mb_temp()
    -- try sensors first
    local result = utils.run_command("sensors")
    local t = get_sensors_temp(result, "temp3")

    if t == nil then
        result = utils.run_command("acpi -t")
        local t1 = get_acpi_temp(result, "Thermal 0")
        local t2 = get_acpi_temp(result, "Thermal 1")
				if t2 == nil then
					t = t1
				else
        	t = math.max(t1, t2)
				end
    end

    if t == nil then
        return colors.title .. "MB Temp" .. cmds.rjust .. colors.warning .. "- - -\n"
    end

    local color, cb = colors.define(t, TEMP_HIGH, TEMP_CRITICAL)

    return colors.title .. "MB Temp".. cmds.rjust .. color .. " +" .. tostring(t) .. "°C" .. "\n"
end


local output = get_mb_temp()
io.write(output)
