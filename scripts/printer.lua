#!/usr/bin/env lua
--
-- Alex Oransky, 2019
-- https://github.com/alexoransky/myconky
--

--
-- The script outputs a conky command to print the printer status.
--
-- Usage:
--   ${execpi <TIME_PERIOD> <PATH>/printer.lua <IP>}:
--   e.g.
--   ${execpi 60 ~/.config/conky/scripts/printer.lua 192.168.0.100}
--

require "colors"
require "cmds"
require "utils"

warning = "moni moniWarning"
level = "class=\"tonerremain\" height=\""

function parse_printer(cmd_result)
    local ref = cmd_result:find(warning)
    local output = "Printer"
    local status = "Ok"
    local color = colors.normal
    if ref ~= nil then
        status = "Warning"
        color = colors.warning
    end
    output = output .. cmds.rjust .. color .. status .. "\n"

    -- find remaining toner string
    local ref = cmd_result:find(level)
    if ref == nil then
        return output
    end

    -- get level
    local p1 = cmd_result:find("t=\"", ref)
    local p2 = cmd_result:find("\"", p1+3)
    local level_str = cmd_result:sub(p1+3, p2-1)
    local level = tonumber(level_str)
    if level == nil then
        return output
    end
    local perc = level*2   -- height is defined in pix out of 50 max
    col, cb = colors.define(100-perc)

    -- get toner color
    local p1 = cmd_result:find(" alt=\"", ref-20)
    local p2 = cmd_result:find("\"", p1+6)
    local toner_color = cmd_result:sub(p1+6, p2-1)

    output = toner_color .. cmds.rjust .. col .. perc .. "% " .. cb .. cmds.lua_bar:gsub("FN", "echo " .. perc) .. "\n"

    return output
end


printer_status_url = "http://<IP>/general/status.html"
local cmd = "curl  -s -X GET " .. printer_status_url

local output = ""
local ip = arg[1]
if ip ~= nil then
    cmd = cmd:gsub("<IP>", ip)
    local cmd_result = utils.run_command(cmd)

    output = parse_printer(cmd_result)
end

io.write(output)
