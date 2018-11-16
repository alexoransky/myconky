#!/usr/bin/env lua

--
-- The script outputs a conky command to print the mother boartd temp
--
-- Usage:
--   ${execpi <TIME_PERIOD> <PATH>/mb_temp.lua}:
--   ${execpi 10 ~/.config/conky/scripts/mb_temp.lua}
--
-- Output:
-- Temp   +25.0°C
--
-- This script implements the conky command below .
-- The script indicates percentage used with color and if there is no
-- specified device, it outputs dashes.
--
-- ${color2}Temp ${color6}${alignr}\
-- ${execi 10 sensors | grep 'temp2' | awk {'print $2'}}
--

--local colors = require("colors")
colors = {}
colors.title = "${color2}"
colors.text  = "${color1}"
colors.normal = "${color6}"
colors.normal_bar = "${color4}"
colors.warning = "${color8}"
colors.critical = "${color9}"

-- conly commands
rjust =  "${alignr}"


function run_command(cmd)
    local handle = io.popen(cmd)
    local result = handle:read("*a")
    handle:close()

    return result
end


function get_temp(s, temp_str)
	local ref = 0
	local temp = ""
    local p1 = 0
    local p2 = 0

	ref = s:find(temp_str)
    if ref == nil then
        return nil
    end

	p1 = s:find("+", ref)
	p2 = s:find("C", p1)
	temp = s:sub(p1, p2-3)

	return tonumber(temp)
end


function get_mb_temp(result)
    t = get_temp(result, "temp3")
    if t == nil then
        return colors.title .. "Temp" .. rjust .. colors.warning .. "- - -\n"
    end

    local color = colors.normal
    if t > 80.0 then
    	color = colors.critical
    elseif t > 65.0 then
    	color = colors.warning
    end
    local output = colors.title .. "Temp".. rjust .. color .. " +" .. tostring(t) .. "°C" .. "\n"

    return output
end


local cmd_result = run_command("sensors")
local output = get_mb_temp(cmd_result)
io.write(output)
