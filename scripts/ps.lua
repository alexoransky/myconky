#!/usr/bin/env lua
--
-- Alex Oransky, 2018
-- https://github.com/alexoransky/myconky
--

--
-- The script outputs a conky command to print the top processes.
--
-- Usage:
--   ${execpi <TIME_PERIOD> <PATH>/ps.lua <CNT> -c|-m|-t [-g]}:
--   <CNT> defines the number of process to print
--   -c will sort by CPU%, -m by Memory% and -t by total% (combined CPU and memory)
--   -g will group processes by the command name and sum up their usage.
--   E.g.
--   ${execp ~/.config/conky/scripts/ps.lua 5 -t -g}
--

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
        if name ~= nil and name ~= "COMMAND" and cpu ~= nil and mem ~= nil and pid ~= nil then
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
        output = output ..  "CPU                           MEM\n"
    else
        output = output ..  "PID          CPU         MEM\n"
    end

    local spaces = ""
    local spaces2 = ""
    local color_mem = colors.normal
    local color_cpu = colors.normal
    for k, v in pairs(sorted) do
        output = output .. colors.normal .. v[NAME] .. cmds.rjust
        if grouped then
            spaces = "                         "
            if v[MEM] < 10.0 then
                spaces = spaces .. "  "
            end
            color_mem = colors.normal
            color_cpu = colors.normal
            if v[CPU] > 200 then
                color_cpu = colors.critical
            elseif v[CPU] > 100 then
                color_cpu = colors.warning
            end
            if v[MEM] > 90 then
                color_mem = colors.critical
            elseif v[MEM] > 75 then
                color_mem = colors.warning
            end
            output = output .. color_cpu .. v[CPU] .. "%" .. spaces .. color_mem .. v[MEM] .. "%\n"
        else
            spaces = "       "
            spaces2 = "       "
            if v[MEM] < 10.0 then
                spaces = spaces .. "  "
            end
            if v[CPU] < 10.0 then
                spaces2 = spaces2 .. "  "
            end
            color_mem = colors.normal
            color_cpu = colors.normal
            if v[CPU] > 200 then
                color_cpu = colors.critical
            elseif v[CPU] > 100 then
                color_cpu = colors.warning
            end
            if v[MEM] > 90 then
                color_mem = colors.critical
            elseif v[MEM] > 75 then
                color_mem = colors.warning
            end
            output = output .. v[PID] .. spaces2 .. color_cpu .. v[CPU] .. "%" .. spaces .. color_mem .. v[MEM] .. "%\n"
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
    local ps = process_results(cmd_result, group)
    local sorted = get_top(ps, cnt, idx)
    local output = get_output(sorted, group)

    io.write(output)
end
