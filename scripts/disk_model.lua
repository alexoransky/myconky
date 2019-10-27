#!/usr/bin/env lua
--
-- Alex Oransky, 2018
-- https://github.com/alexoransky/myconky
--

--
-- The script outputs a conky command to print the model of the
-- specified disk.
--
-- Usage:
--   ${execpi <TIME_PERIOD> <PATH>/disk_model.lua <DEVICE>}:
--   ${execpi 3600 ~/.config/conky/scripts/disk_model.lua sda}
--
-- Output:
-- Disk  LITEON IT LCS-256L9S
--

require "./utils/colors"
require "./utils/cmds"
require "./utils/utils"


function get_disk_info(cmd_result)
    p1 = cmd_result:find("Device Model:")
    if p1 == nil then
        return colors.title .. "Disk " .. cmds.rjust .. "  - - -\n"
    end

    p2 = cmd_result:find("\n", p1)
    local output = utils.ltrim(cmd_result:sub(p1 + 14, p2-1))

    return colors.title .. "Disk " .. cmds.rjust .. colors.text .. output .. "\n"
end

local cmd = "smartctl -i /dev/" .. arg[1]
local result = utils.run_command(cmd)

local output = get_disk_info(result)
io.write(output)
