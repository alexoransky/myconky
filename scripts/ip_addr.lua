#!/usr/bin/env lua
--
-- Alex Oransky, 2018
-- https://github.com/alexoransky/myconky
--

--
-- The script outputs a conky command to print the ip addresses.
--
-- Usage:
--   ${execpi <TIME_PERIOD> <PATH>/ap_addr.lua <interface> [-e]}:
--   <interface> is eno1 or similar.
--   -e will print the external IP address, if obtained, otherwise "---"
--   e.g.
--   ${execpi 60 ~/.config/conky/scripts/ip_addr.lua eno1 -e}
--
-- Output:
-- 192.168.0.10      12.34.567.89
--

require "colors"
require "cmds"
require "utils"

ping = "ping -i 0.2 -c 5 -q "
router_ip = "192.168.0.1"
google_ip = "8.8.8.8"

function get_ip_addr(cmd_result)
    -- parses the output of "curl -s ipinfo.io/ip" command and
    -- forms the output string that conky can parse in its turn

    if cmd_result:find(".") == nil then
        local cmd = ping .. router_ip
        local result = utils.run_command(cmd)
        local time = utils.parse_ping_return(result)
        if time == 0 then
            return cmds.rjust .. colors.critical .. "  ROUTER\n"
        end

        cmd = ping .. google_ip
        result = utils.run_command(cmd)
        time = utils.parse_ping_return(result)
        if time == 0 then
            return cmds.rjust .. colors.critical .. "  ISP\n"
        end

        return cmds.rjust .. colors.warning .. "  - - -\n"
    end

    return cmds.rjust .. colors.normal .. cmd_result
end


local cmd = "curl -s ipinfo.io/ip"

local output = ""
if arg[1] ~= nil then
    local infc = arg[1]
    output = colors.text .. cmds.addr:gsub("XXX", infc) ..
             colors.title ..cmds.center .. "                " .. infc
    if arg[2] == "-e" then
        local cmd_result = utils.run_command(cmd)
        output = output .. get_ip_addr(cmd_result)
    else
        output = output .. "\n"
    end
end

io.write(output)
