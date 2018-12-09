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

backup_ts_fname = ".urbackup_timestamp.txt"
backup_time_entry = "\"last_backup_time\": "
status_entry = "\"success\": "

function read_cached()
    local ts = utils.read_from_file(backup_ts_fname, backup_time_entry)
    if ts == nil then
        return nil
    end
    local time = tonumber(ts:sub(20, -1))

    ts = utils.read_from_file(backup_ts_fname, status_entry)
    if ts == nil then
        return nil
    end
    local status = ts:sub(12, -1)

    return time, status
end

function write_cashed(time, status)
    local output = backup_time_entry .. time .. "\n"
    output = output .. status_entry .. status .. "\n"

    utils.write_to_file(backup_ts_fname, output, true)
end


function parse_finished(cmd_result)
    local time = nil
    local status = nil

    -- get the cached value
    time, status = read_cached()

    -- check if there is a finished backup
    local use_cached = false
    local ref_no_finished = cmd_result:find("\"finished_processes\": [],", nil, true)
    if ref_no_finished ~= nil then
        -- nothing is running and no backup has finished
        -- this can be either right after the installation or after a reboot
        -- check the cached value
        if time == nil then
            -- there is nothing in the cache from the previous backup\
            -- it seems that UrBackup was just installed
            return colors.warning .. "- - -\n"
        end

        -- it seems that a reboot hapenned
        use_cached = true
    end

    if not use_cached then
        -- get the last update
        local ref = cmd_result:find("\"finished_processes\":")
        if ref == nil then
            return colors.critical .. "? ? ?\n"
        end

        -- get the status of the last backup
        local p1 = utils.rfind(cmd_result, status_entry, ref)
        if p1 == nil then
            return colors.critical .. "? ? ?\n"
        end
        local p2 = cmd_result:find("\n", p1)
        status = cmd_result:sub(p1+11, p2-1)

        -- get the last backup time
        p1 = cmd_result:find(backup_time_entry, ref)
        if p1 == nil then
            return colors.critical .. "? ? ?\n"
        end
        p2 = cmd_result:find(",\n", p1)
        time = tonumber(cmd_result:sub(p1+20, p2-1))

        -- store the results
        write_cashed(time, status)
    end

    -- format the age and status for output
    local output = colors.normal .. "OK\n"
    if status ~= "true" then
        output = colors.critical .. "ERROR\n"
    end

    local age, sec = utils.time_since(time)
    local color = colors.normal
    if sec > 86400 then
        color = colors.warning
    end
    output = color .. age .. " ago   " .. output

    return output
end


function parse_running(cmd_result)
    local ref = cmd_result:find("\"running_processes\":")
    if ref == nil then
        return colors.critical .. "? ? ?\n"
    end

    -- get the percentage
    local p1 = cmd_result:find("\"percent_done\": ", ref)
    if p1 == nil then
        return colors.critical .. "? ? ?\n"
    end

    local p2 = cmd_result:find("\n", p1)
    local perc = cmd_result:sub(p1+15, p2-2)

    return colors.normal .. perc .. "%  " ..
           colors.normal_bar .. cmds.lua_bar:gsub("FN", "echo" .. perc) .. "\n"
end


function get_status(cmd_result)
    -- parses the output of "urbackupclientctl status" command

    -- check if the output is valid
    local ref = cmd_result:find("capability_bits")
    if ref == nil then
        return colors.critical .. "- - -\n"
    end

    local ref_no_running = cmd_result:find("\"running_processes\": [],", nil, true)

    -- check if there is a backup in progress
    if ref_no_running == nil then
        return parse_running(cmd_result)
    end

    -- check if there is a finished backup
    return parse_finished(cmd_result)
end


function get_ping(cmd_result)
    -- parses the output of "ping" command

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
