#!/usr/bin/env lua

require "colors"
require "cmds"


-- returns
-- ${color2}Logged In ${alignr}${colorX}${user_number}
function conky_logged_in()
	local user_num = conky_parse(cmds.user_number)
	local color = colors.normal
	if tonumber(user_num) > 1 then
		color = colors.warning
	end
	return colors.title .. "Logged In " .. cmds.rjust .. color .. user_num .. ":  " .. cmds.user_names
end

-- returns
-- ${color2}Load$ {alignr}${color6}${loadavg}
function conky_loadavg()
    local load = conky_parse(cmds.loadavg)

    local output = colors.title .. "Load " .. cmds.rjust
    for ld in string.gmatch(load, "%S+") do
        avg = tonumber(ld)
        color = colors.normal
        if avg > 2.0 then
            color = colors.critical
        elseif avg > 1.0 then
            color = colors.warning
        end
        output = output .. " " .. color .. tostring(string.format("%.2f", avg))
    end

    return output
end

io.write(conky_loadavg())
