#!/usr/bin/env lua

require "colors"
require "fonts"
require "cmds"

--
-- This script contains:
-- 1. Functions that require conky to parse the variable to a value before the
--    value can be used for highlighting.
-- 2. Functions that need to run every cycle.
--
-- This script does not contain functions that require shell commands to run or
-- functions that provide information at a slow rate, such as every our.
-- Those functions are implemented in stand-alone scripts.
--


-- returns
-- ${color2}Logged In ${alignr}${colorX}${user_number}
function conky_logged_in()
	local user_num = conky_parse(cmds.user_number)
	local color = colors.normal
	if tonumber(user_num) > 1 then
		color = colors.warning
	end
	return colors.title .. "Logged In " .. cmds.rjust .. color .. user_num ..
           ":  " .. cmds.user_names
end


-- ${color2}Load$ {alignr}${color6}${loadavg}
-- returns
function conky_loadavg()
    local load = conky_parse(cmds.loadavg)

    local output = colors.title .. "Load " .. cmds.rjust
    for ld in string.gmatch(load, "%S+") do
        avg = tonumber(ld)
        color = colors.normal
        if avg > 5.0 then
            color = colors.critical
        elseif avg > 1.0 then
            color = colors.warning
        end
        output = output .. " " .. color .. tostring(string.format("%.2f", avg))
    end

    return output
end


-- returns
-- ${color2}Uptime ${alignr}${color1} $uptime
function conky_uptime()
    return colors.title .. "Uptime " .. cmds.rjust .. colors.text .. cmds.uptime
end

-- returns
-- ${color3}${font Roboto:size=9:weight:bold}<TITLE> ${hr 2}
-- ${font Roboto:size=9:weight:regular}\
function conky_section(section)
    return colors.section .. fonts.section .. section .. " " .. cmds.line ..
           fonts.text .. "\\"
end


-- returns
--${color7}${cpugraph 20,278 color7 ff0000 -t}
function conky_cpu_graph()
    return colors.normal_bar .. cmds.cpu_gr
end

io.write(conky_loadavg())
