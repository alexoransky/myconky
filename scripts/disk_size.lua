#!/usr/bin/env lua

--
-- The script outputs a conky command to print the imformation for the
-- specified disk and also prints the indicator bar.
--
-- Usage:
--   ${execpi <TIME_PERIOD> <PATH>/disk_size.lua <DEVICE>}:
--   e.g. for /dev/sda3:
--   ${execpi 10 ~/.config/conky/scripts/disk_size.lua sda3}
--
-- Output:
-- /dev/sda3    226G    10% [###                  ]
--
-- This script implements the conky command below plus extra.
-- The script indicates percentage used with color and if there is no
-- specified device, it outputs dashes.
--
--   ${exec df -h | grep /dev/sda3 | awk '{print $1}'}\
--   ${exec df -h | grep /dev/sda3 | awk '{print $2}'}\
--   ${alignr}${exec df -h | grep /dev/sda3 | awk '{print $5}'}  \
--   ${fs_bar 6,110}
--

require "colors"
require "cmds"
require "utils"


function get_size_mnt(cmd_out, dev_str)
    -- parses the output of df -h and returns the info on the specified dev
    -- input
    --   cmd_out:
    --     /dev/sda1       128G   64G   64G  50% /etc
    --     /dev/sda3       226G   20G  195G   9% /
    --   dev_str: "/dev/sdaX"
    -- returns:
    --   total size (str)
    --   percentage used (int)
    --   the mount point (str)

    -- find /dev/sdXY
	local ref = cmd_out:find(dev_str)
    if ref == nil then
        return nil
    end

    -- get the "size, used ... / \n" for the found device
    local p1 = cmd_out:find("\n", ref)
	local temp = cmd_out:sub(ref + #dev_str, p1)

    -- split into words
    local words = {}
    for word in temp:gmatch("%w+") do table.insert(words, word) end
    local size = tonumber(words[1]:sub(1, -2))
    local perc = tonumber(words[4])
    local mnt = words[5]
    if mnt == nil then
        mnt = "/"
    else
        mnt = "/" .. mnt
    end
    if words[6] ~= nil then
        mnt = mnt .. "/" .. words[6]
    end

    return words[1], perc, mnt
end


function get_dev_info(cmd_result, dev_id)
    -- parses the output of df -h command for the specified device and
    -- forms the output string that conky can parse in its turn

    size, perc, mnt = get_size_mnt(cmd_result, dev_id)
    if size == nil then
        return colors.title .. dev_id .. cmds.tab50 .. "  - - -\n"
    end

    local color = colors.normal
    local color_bar = colors.normal_bar
    if perc > 90 then
    	color = colors.critical
        color_bar = colors.critical
    elseif perc > 75 then
    	color = colors.warning
        color_bar = colors.warning
    end

    local output = colors.title .. dev_id .. cmds.tab50 .. colors.text .. size ..
                   cmds.rjust .. color .. perc .. "%  " .. color_bar .. cmds.fsbar .. mnt .. "}\n"

    return output
end


local cmd_result = utils.run_command("df -h")
local dev_id = "/dev/" .. arg[1]

local output = get_dev_info(cmd_result, dev_id)
io.write(output)
