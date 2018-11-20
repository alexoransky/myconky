#!/usr/bin/env lua

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


function get_ip_addr(cmd_result)
    -- parses the output of df -h command for the specified device and
    -- forms the output string that conky can parse in its turn

    if cmd_result:find(".") == nil then
        return cmds.rjust .. colors.title .. "  - - -\n"
    end

    return cmds.rjust .. colors.text .. cmd_result
end


local output = ""
if arg[1] ~= nil then
    output = colors.text .. cmds.addr:gsub("XXX", arg[1])
    if arg[2] == "-e" then
        local cmd_result = utils.run_command("curl ipinfo.io/ip")
        output = output .. get_ip_addr(cmd_result)
    else
        output = output .. "\n"
    end
end

io.write(output)
