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
local cjson = require "cjson.safe"

backup_ts_fname = ".urbackup_timestamp.txt"

running_processes = "running_processes"
percent_done = "percent_done"

finished_processes = "finished_processes"
last_backup_time = "last_backup_time"
success = "success"

function read_saved()
    local s = utils.read_file(backup_ts_fname)
    if s == nil then
        return nil
    end

    local cr = cjson.decode(s)
    if cr == nil then
        return nil
    end

    local time = cr[last_backup_time]
    if time == nil then
        return nil
    end
    local time = math.floor(time)

    local status = cr[success]
    if status == nil then
        return nil
    end

    return time, status
end

function write_saved(time, status)
    local output = "\"" .. last_backup_time .. "\": " .. time .. ",\n"
    output = "{\n" .. output .. "\"" .. success .. "\": " .. status .. "\n}\n"

    utils.write_to_file(backup_ts_fname, output, true)
end


function prepare_output(time, success)
    -- format the age and status for output
    local output = colors.normal .. "OK\n"
    if not success then
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


function parse_running(proc)
    -- get the percentage
    local perc = proc[percent_done]
    if perc == nil then
        return colors.critical .. "? ? ?\n"
    end

    perc = math.floor(perc)
    return colors.normal .. perc .. "%  " ..
           colors.normal_bar .. cmds.lua_bar:gsub("FN", "echo " .. perc) .. "\n"
end


function parse_finished(proc, time)
    if time == nil then
        return colors.critical .. "? ? ?\n"
    end

    local status = proc[success]
    if status == nil then
        return colors.critical .. "? ? ?\n"
    end

    time = math.floor(time)
    write_saved(time, tostring(status))

    return prepare_output(time, status)
end


function parse_saved()
    local time = nil
    local status = nil

    -- get the cached value
    time, status = read_saved()

    -- check the cached value
    if time == nil then
        -- there is nothing in the cache from the previous backup
        -- it seems that UrBackup was just installed
        return colors.warning .. "- - -\n"
    end

    -- it seems that a reboot hapenned
    return prepare_output(time, status)
end


function get_status(cmd_result)
    -- parses the output of "urbackupclientctl status" command
    -- check if the output is valid
    local cr = cjson.decode(cmd_result)
    if cr == nil then
        return colors.critical .. "- - -\n"
    end

    -- check if there is a backup in progress
    local procs = cr[running_processes]
    if procs ~= nil then
        local proc = procs[1]
        if proc ~= nil then
            return parse_running(proc)
        end
    end

    -- check if there is a finished backup
    local procs = cr[finished_processes]
    if procs ~= nil then
        local proc = procs[#procs]
        if proc ~= nil then
            local time = cr[last_backup_time]
            return parse_finished(proc, time)
        end
    end

    -- nothing is running and no backup has finished
    -- this can be either right after the installation or after a reboot
    return parse_saved()
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
local cmd_result

if arg[1] ~= nil then
    local ip = arg[1]
    cmd_ping = cmd_ping .. ip
    cmd_result = utils.run_command(cmd_ping)
    output = output .. cmds.tab40 .. get_ping(cmd_result)
end

cmd_result = utils.run_command(cmd_status)
output = output .. cmds.rjust .. get_status(cmd_result)

io.write(output)
