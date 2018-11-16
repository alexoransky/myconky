#!/usr/bin/env lua

--
-- The script outputs a conky command to print the CPU core temp and show
-- the cpu percentage bar.
--
-- Usage:
--   ${execpi <TIME_PERIOD> <PATH>/core_info.lua <CORE ID>}:
--   <CORE ID> is 0, 1, etc.
--   ${execpi 3600 ~/.config/conky/scripts/core_info.lua 0}
--
-- Output:
-- 1: +50°C   5%  [####     ]
--

--local colors = require("colors")
colors = {}
colors.title = "${color2}"
colors.normal = "${color6}"
colors.normal_bar = "${color4}"
colors.warning = "${color8}"
colors.critical = "${color9}"

-- conky commands
rjust =  "${alignr}"
tab = "${tab 24}"
cpu = "${cpu cpuX}"
bar = "${cpubar cpuX 6, 100}"


function run_command(cmd)
    local handle = io.popen(cmd)
    local result = handle:read("*a")
    handle:close()

    return result
end


function get_temp(s, temp_str, high_str, crit_str)
	local ref = 0
	local temp = ""
	local high = ""
    local crit = ""
    local p1 = 0
    local p2 = 0

	ref = s:find(temp_str)
    if ref == nil then
        return nil
    end

    p1 = s:find("+", ref)
	p2 = s:find("C", p1)
	temp = s:sub(p1, p2-3)

    ref = s:find(high_str)
    if ref == nil then
        return nil
    end

	p1 = s:find("+", p1+1)
	p2 = s:find("C", p1)
	high = s:sub(p1, p2-3)

	ref = s:find(crit_str)
    if ref == nil then
        return nil
    end

	p1 = s:find("+", p2+1)
	p2 = s:find("C", p1)
	crit = s:sub(p1, p2-3)

	return tonumber(temp), tonumber(high), tonumber(crit)
end


function get_cpu_info(cmd_result, dev_id, cpu_num)
    t, h, c = get_temp(cmd_result, dev_id, "high", "crit")
    if t == nil then
        io.write(colors.warning .. "---\n")
        do return end
    end

    local color = colors.normal
    if t > c then
    	color = colors.critical
    elseif t > h then
    	color = colors.warning
    end

    cpu_str = "cpu" .. cpu_num

    local output = colors.title .. cpu_num .. tab .. color .. "+" .. tostring(t) .. "°C "
    output = output .. rjust .. color .. cpu:gsub("cpuX", cpu_str) .. "%  " .. colors.normal_bar .. bar:gsub("cpuX", cpu_str) .. "\n"

    return output
end


local cmd_result = run_command("sensors")
local dev_id = "Core " .. arg[1]
local cpu_num = tonumber(arg[1]) + 1

local output = get_cpu_info(cmd_result, dev_id, cpu_num)
io.write(output)
