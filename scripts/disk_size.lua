#!/usr/bin/env lua

--
-- The script outputs a conky command to print the imformation for the
-- specified disk and also prints the indicator bar.
--
-- Usage:
--   ${execpi <TIME_PERIOD> <PATH>/disk_size.lua [<DEVICE>]}:
--   e.g. for /dev/sda3:
--   ${execpi 10 ~/.config/conky/scripts/disk_size.lua sda3}
--   if <DEVICE> is skipped, will print info on available /dev/sdaX and sdbX.
--
-- Output:
-- /dev/sda3    226G    10% [###                  ]
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

    local words = utils.split_str(temp)
    local size = tonumber(words[1]:sub(1, -2))
    local perc = tonumber(words[4]:sub(1, -2))
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


function get_dev_info(cmd_result, dev_id, dashes)
    -- parses the output of df -h command for the specified device and
    -- forms the output string that conky can parse in its turn

    size, perc, mnt = get_size_mnt(cmd_result, dev_id)
    if size == nil then
        if dashes then
            return colors.title .. dev_id .. cmds.tab50 .. "  - - -\n"
        else
            return nil
        end
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
local dev_id = ""
local output = ""
local result = nil

if arg[1] == nil then
    -- output for all available sdaX and sdbX
    for c = 97, 98 do
        dev_id_base = "/dev/sd" .. string.char(c)
        for i = 1, 9 do
            dev_id = dev_id_base .. string.char(i+48)
            result = get_dev_info(cmd_result, dev_id, false)
            if result == nil then
                break
            end
            output = output .. result
        end
    end
else
    dev_id = "/dev/" .. arg[1]
    output = get_dev_info(cmd_result, dev_id, true)
end

io.write(output)
