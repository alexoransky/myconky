#!/usr/bin/env lua
--
-- Alex Oransky, 2018
-- https://github.com/alexoransky/myconky
--

--
-- The script outputs a conky command to print the status of the backup in
-- progress or the last backup for UrBackup client.
--
-- Usage:
--   ${execpi <TIME_PERIOD> <PATH>/urbackup.lua [IP]}:
--   IP is the IP address of the UrBackup server.  If specified,
--   the ping time will be printed, as in ping.lua.
--   e.g.
--   ${execpi 60 ~/.config/conky/scripts/urbackup.lua 192.168.0.100}
--
-- Output:
-- Backup   0.345 ms    4h 45m ago  OK
--

require "colors"
require "cmds"
require "utils"
require "nd"

-- cpu_temp = "cpu.temperature"
uptime = "system.uptime"
load = "system.load"

-- function get_temp(cmd_result)
--     v1 = nd.get_value(cmd_result, 1)
--     v2 = nd.get_value(cmd_result, 2)
--     if v1 == nil then
--         return colors.critical .. "- - -"
--     end
--     local v = v1
--     if v2 ~= nil then
--         v = math.max(v1, v2)
--     end
--
--     return colors.normal .. v
-- end

function get_uptime(cmd_result)
    local result = colors.title .. "Uptime" .. cmds.rjust

    v = nd.get_value(cmd_result, 1)
    if v == nil then
        return result .. colors.warning .. "- - -"
    end

    return result .. colors.normal .. utils.sec_to_human(v)
end

function get_load(cmd_result)
    local output = colors.title .. "Load" .. cmds.rjust

    local vals = nd.get_values(cmd_result)
    for i = 1, #vals do
        color = colors.normal
        if vals[i] > 5.0 then
            color = colors.critical
        elseif vals[i] > 1.0 then
            color = colors.warning
        end
        output = output .. " " .. color .. tostring(string.format("%.2f", vals[i]))
    end

    return output
end


local cmd_result
local output = ""

if arg[1] ~= nil then
    local ip = arg[1]

    -- local cmd_temp = nd.cmd(ip, cpu_temp)
    local cmd_uptime = nd.cmd(ip, uptime)
    local cmd_load = nd.cmd(ip, load)

    -- cmd_result = utils.run_command(cmd_temp)
    -- output = output .. cmds.tab40 .. get_temp(cmd_result) .. "\n"

    cmd_result = utils.run_command(cmd_uptime)
    output = get_uptime(cmd_result) .. "\n"

    cmd_result = utils.run_command(cmd_load)
    output = output .. get_load(cmd_result) .. "\n"
end

io.write(output)
