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

-- {
-- "capability_bits": 64,
-- "finished_processes": [{
-- "process_id": 1,
-- "success": true
-- }
-- ,{
-- "process_id": 2,
-- "success": true
-- }
-- ],
-- "internet_connected": false,
-- "internet_status": "connected_local",
-- "last_backup_time": 1543776838,
-- "running_processes": [],
-- "servers": [{
-- "internet_connection": false,
-- "name": "192.168.0.20"
-- }
-- ],
-- "time_since_last_lan_connection": 1761
-- }
function parse_finished(cmd_result)
    local ref = cmd_result:find("\"finished_processes\":")
    if ref == nil then
        return colors.warning .. "- - -\n"
    end

    -- get the status of the last backup
    local p1 = utils.rfind(cmd_result, "\"success\": ", ref)
    if p1 == nil then
        return colors.warning .. "? ? ?\n"
    end

    local p2 = cmd_result:find("\n", p1)
    local status = cmd_result:sub(p1+11, p2-1)

    local output = colors.normal .. "OK\n"
    if status ~= "true" then
        output = colors.critical .. "ERROR\n"
    end

    -- get the last backup time
    local p1 = cmd_result:find("\"last_backup_time\": ", ref)
    if p1 == nil then
        return output
    end

    local p2 = cmd_result:find(",\n", p1)
    local last = tonumber(cmd_result:sub(p1+20, p2-1))
    local age, sec = utils.time_since(last)

    local color = colors.normal
    if sec > 86400 then
        color = colors.warning
    end
    output = color .. age .. " ago   " .. output

    return output
end

-- {
-- "capability_bits": 64,
-- "finished_processes": [{
-- "process_id": 1,
-- "success": true
-- }
-- ],
-- "internet_connected": false,
-- "internet_status": "connected_local",
-- "last_backup_time": 1543759970,
-- "running_processes": [{
-- "action": "INCR",
-- "done_bytes": 172439453,
-- "eta_ms": 0,
-- "percent_done": 100,
-- "process_id": 2,
-- "server_status_id": 12,
-- "speed_bpms": 196.25,
-- "total_bytes": 172492968
-- }
-- ],
-- "servers": [{
-- "internet_connection": false,
-- "name": "192.168.0.20"
-- }
-- ],
-- "time_since_last_lan_connection": 6456
-- }
--

-- {
-- "capability_bits": 64,
-- "finished_processes": [],
-- "internet_connected": false,
-- "internet_status": "connected_local",
-- "last_backup_time": 0,
-- "running_processes": [{
-- "action": "FULL",
-- "done_bytes": 9477753279,
-- "eta_ms": 326867,
-- "percent_done": 73,
-- "process_id": 1,
-- "server_status_id": 11,
-- "speed_bpms": 593.666,
-- "total_bytes": 12926481557
-- }
-- ],
-- "servers": [{
-- "internet_connection": false,
-- "name": "192.168.0.20"
-- }
-- ],
-- "time_since_last_lan_connection": 3063
-- }
function parse_running(cmd_result)
    local ref = cmd_result:find("\"running_processes\":")
    if ref == nil then
        return colors.warning .. "- - -\n"
    end

    -- get the percentage
    local p1 = cmd_result:find("\"percent_done\": ", ref)
    if p1 == nil then
        return colors.warning .. "? ? ?\n"
    end

    local p2 = cmd_result:find("\n", p1)
    local perc = cmd_result:sub(p1+15, p2-2)

    return colors.normal .. perc .. "%  " ..
           colors.normal_bar .. cmds.lua_bar:gsub("FN", "echo" .. perc) .. "\n"
end


function get_status(cmd_result)
    -- parses the output of "urbackupclient status" command and
    -- forms the output string that conky can parse in its turn

    local ref_no_running = cmd_result:find("\"running_processes\": [],", nil, true)
    local ref_no_finished = cmd_result:find("\"finished_processes\": [],", nil, true)

    -- nothing running and nothing has finished: nothing ever started
    if ref_no_running ~= nil and ref_finished ~= nil then
        return colors.warning .. "- - -\n"
    end

    -- check if there is a backup in progress
    if ref_no_running == nil then
        return parse_running(cmd_result)
    end

    -- check if there is a finished backup
    return parse_finished(cmd_result)
end


function get_ping(cmd_result)
    -- parses the output of "ping" command and
    -- forms the output string that conky can parse in its turn

    local time = utils.parse_ping_return(cmd_result)

    if time == 0 then
        return colors.critical .. "- - -"
    end

    local color = colors.normal
    if time > 0.9 then
        color = colors.warning
    end

    return color .. time .. " ms"
end


local cmd_status = "urbackupclientctl status"
local cmd_ping = "ping -i 0.2 -c 5 -q "

local output = colors.title .. "Backup"
local cmd_result = ""

if arg[1] ~= nil then
    local ip = arg[1]
    cmd_ping = cmd_ping .. ip
    cmd_result = utils.run_command(cmd_ping)
    output = output .. cmds.tab40 .. get_ping(cmd_result)
end

cmd_result = utils.run_command(cmd_status)
output = output .. cmds.rjust .. get_status(cmd_result)

io.write(output)
