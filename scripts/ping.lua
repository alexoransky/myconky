#!/usr/bin/env lua
--
-- Alex Oransky, 2018
-- https://github.com/alexoransky/myconky
--

--
-- The script outputs a conky command to print if the specified host available.
--
-- Usage:
--   ${execpi <TIME_PERIOD> <PATH>/ping.lua <ip> [<title>]}:
--   e.g.
--   ${execpi 60 ~/.config/conky/scripts/ping.lua 192.168.0.100 NAS}
--
-- Output:
-- NAS   0.345 ms
--

require "./utils/colors"
require "./utils/cmds"
require "./utils/utils"


function get_status(cmd_result)
    -- parses the output of "ping" command and
    -- forms the output string that conky can parse in its turn

    local time = utils.parse_ping_return(cmd_result)

    if time == 0 then
        return cmds.rjust .. colors.critical .. "  - - -\n"
    end

    local color = colors.normal
    if time > 0.9 then
        color = colors.warning
    end

    return cmds.rjust .. color .. time .. " ms \n"
end


local cmd = "ping -i 0.2 -c 5 -q "
local output = ""
if arg[1] ~= nil then
    local ip = arg[1]
    local title = arg[2]

    if title == nil then
        output = colors.text .. ip .. cmds.rjust
    else
        output = colors.title .. title .. cmds.rjust
    end

    cmd = cmd .. ip
    local cmd_result = utils.run_command(cmd)
    output = output .. get_status(cmd_result)
end

io.write(output)
