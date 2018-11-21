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
--   ${execpi 3600 ~/.config/conky/scripts/cpu_info.lua -a}
--
-- Output:
-- 2.74 GHz:   +50°C   5%  [####     ]
-- 1:          +50°C   5%  [####     ]
--
-- The script requires lm-sensors installed.

require "colors"
require "cmds"
require "utils"


MEM = 1
CPU = 2
TOTAL = 3
PROCESSED = 4
NAME = 5
PID = 6


function get_info(s)
    tokens = utils.split_str(s)
	return tokens[2], tonumber(tokens[3]), tonumber(tokens[4]), tonumber(tokens[1])
end


function process_results(cmd_result, group)
    local ps = {}
    local i = 1

    for line in cmd_result:gmatch("[^\r\n]+") do
        name, mem, cpu, pid = get_info(line)
        if name ~= "COMMAND" then
            if group then
                if mem ~= 0 or cpu ~= 0 then
                    if ps[name] == nil then
                        local info = {}
                        info[MEM] = mem
                        info[CPU] = cpu
                        info[TOTAL] = mem + cpu
                        info[PROCESSED] = false
                        info[NAME] = name
                        info[PID] = -1
                        ps[name] = info
                    else
                        local info = ps[name]
                        info[MEM] = info[MEM] + mem
                        info[CPU] = info[CPU] + cpu
                        info[TOTAL] = info[TOTAL] + mem + cpu
                    end
                end
            else
                if mem ~= 0 or cpu ~= 0 then
                    local info = {}
                    info[MEM] = mem
                    info[CPU] = cpu
                    info[TOTAL] = mem + cpu
                    info[PROCESSED] = false
                    info[NAME] = name
                    info[PID] = pid
                    ps[i] = info
                    i = i+1
                end
            end
        end
    end

    return ps
end


-- the function returns the top "cnt" processes from "ps" table
-- "idx" is either MEM, CPU or TOTAL
function get_top(ps, cnt, idx)
    local sorted = {}
    local max = -1
    local found = ""
    local info = {}

    for i = 1, cnt do
        max = -1
        found = ""
        for k, v in pairs(ps) do
            if v[idx] > max and not v[PROCESSED] then
                max = v[idx]
                found = k
            end
        end

        info = ps[found]
        info[PROCESSED] = true

        sorted[i] = info
    end

    return sorted
end


function get_output(sorted, grouped)
    local output = colors.title .. "NAME" .. cmds.rjust
    if grouped then
        output = output ..  "CPU                           MEM\n" .. colors.normal
    else
        output = output ..  "PID          CPU         MEM\n" .. colors.normal
    end

    local spaces = ""
    local spaces2 = ""
    for k, v in pairs(sorted) do
        output = output .. v[NAME] .. cmds.rjust
        if grouped then
            spaces = "                         "
            if v[MEM] < 10.0 then
                spaces = spaces .. "  "
            end
            output = output .. v[CPU] .. "%" .. spaces .. v[MEM] .. "%\n"
        else
            spaces = "       "
            spaces2 = "       "
            if v[MEM] < 10.0 then
                spaces = spaces .. "  "
            end
            if v[CPU] < 10.0 then
                spaces2 = spaces2 .. "  "
            end
            output = output .. v[PID] .. spaces2 .. v[CPU] .. "%" .. spaces .. v[MEM] .. "%\n"
        end
    end

    return output
end


local cnt = arg[1]
local idx = TOTAL
local group = false

if arg[2] == "-m" then
    idx = MEM
end
if arg[2] == "-c" then
    idx = CPU
end

if arg[3] == "-g" then
    group = true
end

if cnt ~= nil then
    local cmd_result = utils.run_command("ps -eo pid,comm,%mem,%cpu")
    local output = ""
    local ps = process_results(cmd_result, group)
    local sorted = get_top(ps, cnt, idx)
    local output = get_output(sorted, group)

    io.write(output)
end
