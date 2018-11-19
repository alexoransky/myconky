#!/usr/bin/env lua

--
-- The script outputs a conky command to print the CPU frequency, core temp and
-- show the cpu percentage bar.
--
-- Usage:
--   ${execpi <TIME_PERIOD> <PATH>/cpu_info.lua [options]}:
--   options:
--   -a: (all)- prints CPU freq, CPU temp, CPU percentage and CPU utilization
--              bar and prints the core temp, core percentage and core
--              utilization bar for each core.
--   <CORE ID>: is the core #: 0, 1, etc. Prints the core temp, core percentage
--              and core utilization bar
--   When options is skipped, prints CPU freq, CPU temp, CPU percentage and CPU
--   utilization bar.
--
--   ${execpi 3600 ~/.config/conky/scripts/cpu_info.lua}
--   ${execpi 3600 ~/.config/conky/scripts/cpu_info.lua 0}
--   ${execpi 3600 ~/.config/conky/scripts/cpu_info.lua -all}
--
-- Output:
-- 2.74 GHz:   +50°C   5%  [####     ]
-- 1:          +50°C   5%  [####     ]
--
-- The script requires lm-sensors installed.

require "colors"
require "utils"

-- conky commands
rjust =  "${alignr}"
tab = "${tab 40}"
cpu = "${cpu cpuX}"
freq = "${freq_g}"
bar = "${cpubar cpuX 6, 100}"


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
        return colors.warning .. "---\n"
    end

    local color = colors.normal
    if t > c then
    	color = colors.critical
    elseif t > h then
    	color = colors.warning
    end

    local cpu_str = "cpu" .. cpu_num
    local core_str = colors.title .. tostring(cpu_num)
    if cpu_num == 0 then
        core_str = colors.text .. freq .. " GHz"
    end

    local output = core_str .. tab .. color .. "+" .. tostring(t) .. "°C "
    output = output .. rjust .. color .. cpu:gsub("cpuX", cpu_str) .. "%  " .. colors.normal_bar .. bar:gsub("cpuX", cpu_str) .. "\n"

    return output
end


local cmd_result = utils.run_command("sensors")
local dev_id = "Package id 0"
local cpu_num = 0
local max_cnt = 0
local output = ""

if arg[1] == "-a" then
    max_cnt = utils.count_substr(cmd_result, "Core ")
    output = get_cpu_info(cmd_result, dev_id, cpu_num)
    for i = 0, max_cnt-1 do
        dev_id = "Core " .. i
        cpu_num = tonumber(i) + 1
        output = output .. get_cpu_info(cmd_result, dev_id, cpu_num)
    end
else
    if arg[1] ~= nil then
        dev_id = "Core " .. arg[1]
        cpu_num = tonumber(arg[1]) + 1
    end

    output = get_cpu_info(cmd_result, dev_id, cpu_num)
end

io.write(output)
