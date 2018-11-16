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

	p1 = s:find(": ", ref+1)
	p2 = s:find("C", p1)
	temp = s:sub(p1+2, p2-3)

	return tonumber(temp)
end


function get_hdd_temp(result)
    t = get_temp(result, ": ")
    if t == nil then
        return colors.title .. "Disk Temp" .. rjust .. colors.warning .. "- - -\n"
    end

    local color = colors.normal
    if t > 80.0 then
    	color = colors.critical
    elseif t > 65.0 then
    	color = colors.warning
    end
    local output = colors.title .. "Disk Temp".. rjust .. color .. " +" .. tostring(t) .. "°C" .. "\n"

    return output
end

local cmd_result = run_command("hddtemp " .. arg[1])
local output = get_hdd_temp(cmd_result)
io.write(output)
