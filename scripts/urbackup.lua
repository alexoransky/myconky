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
require "fonts"
local cjson = require "cjson.safe"

backup_ts_fname = ".urbackup_timestamp.txt"

running_processes = "running_processes"
percent_done = "percent_done"

finished_processes = "finished_processes"
last_backup_time = "last_backup_time"
success = "success"
action = "action"
speed = "speed_bpms"
total_size = "total_bytes"

one_day = 86400

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
    local status = colors.normal .. "Backup: OK\n"
    if not success then
        status = colors.critical .. "Backup: FAILED\n"
    end

    local age, sec = utils.time_since(time)
    local color = colors.normal
    if sec > one_day then
        color = colors.warning
    end
    output = colors.title .. "Latest" .. cmds.tab40 .. color .. age .. " ago   " .. cmds.rjust .. status

    return output
end


function parse_running(proc)
    -- get the percentage
    local perc = proc[percent_done]
    if perc == nil then
        return colors.title .. "In progress" .. cmds.rjust .. colors.warning .. "? ? ?\n"
    end
    perc = math.floor(perc)

    local act = proc[action]
    local size = proc[total_size] / 1024 / 1024   -- convert bytes to Mb
    local unit = "M"
    if size >= 1023.5 then
        size = size / 1024  -- convert to Gb
        unit = "G"
    end
    size = utils.round(size, 1)

    return fonts.text .. act .. cmds.tab40 .. size .. unit .. cmds.rjust .. perc .. "%  " ..
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
    local in_progress = ""
    if procs ~= nil then
        local proc = procs[1]
        if proc ~= nil then
            in_progress = parse_running(proc)
        end
    end

    -- check if there is a finished backup
    local procs = cr[finished_processes]
    if procs ~= nil then
        local proc = procs[#procs]
        if proc ~= nil then
            local time = cr[last_backup_time]
            return parse_finished(proc, time) .. in_progress
        end
    end

    -- no backup has finished
    -- this can be either right after the installation or after a reboot
    return parse_saved() .. in_progress
end


local cmd_status = "urbackupclientctl status"
local cmd_result = utils.run_command(cmd_status)
local output = get_status(cmd_result)

io.write(output)
