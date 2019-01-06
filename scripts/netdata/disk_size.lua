#!/usr/bin/env lua
--
-- Alex Oransky, 2018
-- https://github.com/alexoransky/myconky
--

--
-- The script outputs a conky command to print the imformation for the
-- specified disk and also prints the indicator bar.
--
-- Usage:
--   ${execpi <TIME_PERIOD> <PATH>/disk_size.lua [<DEVICE>  <DEVICE> ...]}:
--   e.g. for /dev/sda3 and /dev/sdb1:
--   ${execpi 10 ~/.config/conky/scripts/disk_size.lua sda3 sdb1}
--   if <DEVICE>s are skipped, will print info on available /dev/sdaX and sdbX.
--   Note that if the device is not mounted, there will be no ooutput.
--
-- Output:
-- /dev/sda3    226G    10% [###                  ]
--

require "colors"
require "cmds"
require "utils"
require "nd"

disk_space = "disk_space._mnt_SERVER_"

FREE = 2  -- "avail"
USED = 3

function get_disk_vals(vals)
    local total = 0
    -- timestamp is #1, so start iterating from #2
    for i = 2, #vals do
        total = total + vals[i]
    end

    local free = 0
    local used = total
    local perc = 100
    if #vals >= FREE then
        free = free + vals[FREE]
    end
    used = total - free

    if total > 0 then
        perc = utils.round(used * 100 / total, 1)
    end

    return total, perc
end


function format_size(val_gb)
    local val = val_gb
    local unit = "G"

    if val_gb >= 1023.5 then
        val = val_gb / 1024
        unit = "T"
        return utils.round(val, 1) .. unit
    end

    if val_gb < 0.95 then
        val = val_gb * 1024
        unit = "M"
    end

    return utils.round(val) .. unit
end


function get_dev_info(cmd_result, dev_id)
    local vals = nd.get_values(cmd_result)
    if vals == nil then
        return colors.title .. dev_id .. cmds.rjust .. colors.warning .. "- - -\n"
    end

    local disk_total, disk_perc = get_disk_vals(vals)

    local color, color_bar = colors.define(disk_perc)

    -- the value is in Gb, convert/format for proper display
    local size = format_size(disk_total)

	local output = colors.title .. dev_id .. cmds.tab40 .. colors.text .. size ..
                   cmds.rjust .. color .. disk_perc ..
                   "%  " .. color_bar .. cmds.lua_bar:gsub("FN", "echo " .. disk_perc) .. "\n"

    return output
end


local cmd_result = ""
local dev_id = ""
local cmd_disk = ""
local ds = ""
local output = ""
local result = nil

if arg[1] ~= nil then
    local ip = arg[1]
    for i = 2, #arg do
        dev_id = "/" .. arg[i]
        ds = disk_space .. arg[i]
        cmd_disk = nd.cmd(ip, ds)
        cmd_result = utils.run_command(cmd_disk)
        result =  get_dev_info(cmd_result, dev_id)
        output = output .. result
    end
end

io.write(output)
