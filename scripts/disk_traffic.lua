#!/usr/bin/env lua

--
-- The script outputs a conky command to display the disk traffic for the
-- specified disk.
--
-- Usage:
--   ${execpi <TIME_PERIOD> <PATH>/disk_traffic.lua <DEVICE> [<DEVICE> ...]}:
--   e.g. for /dev/sda3 and /dev/sdb1:
--   ${execpi 10 ~/.config/conky/scripts/disk_traffic.lua sda3 sdb1}
--   Note that if the device is not mounted, there will be no ooutput.
--

require "colors"
require "fonts"
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


function get_dev_traffic(dev_id)
    local output = colors.normal .. fonts.symbols .. "▼  " .. fonts.text ..
                   cmds.diskio_write:gsub("/dev/sdXY", dev_id) ..
                   colors.title .. cmds.center .. "          " .. dev_id ..
                   colors.normal .. cmds.rjust .. cmds.diskio_read:gsub("/dev/sdXY", dev_id) ..
                   fonts.symbols .. "  ▲" .. fonts.text .. "\n" ..
                   colors.normal_bar .. cmds.disk_write_gr:gsub("/dev/sdXY", dev_id) ..
                   cmds.rjust .. cmds.disk_read_gr:gsub("/dev/sdXY", dev_id) .. "\n"
    return output
end


local cmd_result = utils.run_command("df -h")
local dev_id = ""
local output = ""
local result = ""
local size = nil

for i = 1, #arg do
    dev_id = "/dev/" .. arg[i]
    size, _, _ = get_size_mnt(cmd_result, dev_id)
    if size ~= nil then
        result = get_dev_traffic(dev_id)
        output = output .. result
    end
end

io.write(output)
