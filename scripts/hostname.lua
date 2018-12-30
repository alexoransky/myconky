#!/usr/bin/env lua
--
-- Alex Oransky, 2018
-- https://github.com/alexoransky/myconky
--

--
-- The script outputs a conky command to print the host name for the given IP.
--
-- Usage:
--   ${execpi <TIME_PERIOD> <PATH>/hostname.lua <ip>}:
--   e.g.
--   ${execpi 60 ~/.config/conky/scripts/ping.lua 192.168.0.100}
--
-- Output:
-- NAS   192.168.0.100
--
-- Notes:
-- Currently supports avahi-resolve only.

require "colors"
require "cmds"
require "utils"


function get_name(cmd_result)
    -- parses the output of "avahi0resolve -a" command, e.g.
    -- 192.168.0.100    NAS.local
    -- and forms the output string that conky can parse in its turn

    local p = cmd_result:find("Failed to resolve address")
    if p ~= nil then
        return colors.warning .. "- - -"
    end

    local ref = cmd_result:find("\t")
    if ref == nil then
        return colors.warning .. "- - -"
    end

    host = cmd_result:sub(ref+1)
    p = host:find(".local")
    if p ~= nil then
        host = host:sub(1, p-1)
    end

    return colors.normal .. host
end


local cmd = "avahi-resolve -a "
local output = ""
if arg[1] ~= nil then
    local ip = arg[1]

    cmd = cmd .. ip
    local cmd_result = utils.run_command(cmd)
    output = colors.text .. ip .. cmds.rjust .. get_name(cmd_result) .. "\n"
end

io.write(output)
