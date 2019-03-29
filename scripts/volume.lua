#!/usr/bin/env lua
--
-- Alex Oransky, 2019
-- https://github.com/alexoransky/myconky
--

--
-- The script outputs a conky command to print the volume bars.
--
-- Usage:
--   ${execpi <TIME_PERIOD> <PATH>/volume.lua <IP>}:
--   e.g.
--   ${execpi 60 ~/.config/conky/scripts/volume.lua}
--

require "colors"
require "cmds"
require "utils"

local cmd = "amixer get Master"

local left = "Front Left:"
local right = "Front Right:"

function get_volume(s, ss)
    local perc = -1
    local status = "off"

    if s ~= "" then
        local ref = s:find(ss)
        if ref ~= nil then
            local p1 = s:find("%[", ref)
            local p2 = s:find("%]", p1+1)
            perc = s:sub(p1+1, p2-2)

            local p1 = s:find("%[", p2+1)
            local p2 = s:find("%]", p1+1)
            status = s:sub(p1+1, p2-1)
        end
    end

    local col = colors.warning
    local col_bar = colors.warning_bar
    if status == "on" then
        col = colors.normal
        col_bar = colors.normal_bar
    end

    return tonumber(perc), col, col_bar
end

function parse_result(cmd_result)
    local col, col_bar
    local perc = "0"
    local output = ""
    if cmd_result ~= "" then
        perc, col, col_bar = get_volume(cmd_result, left)
        output = output .. colors.title .. "Left" .. cmds.rjust .. col .. perc .. "% " .. col_bar .. cmds.lua_bar:gsub("FN", "echo " .. perc) .. "\n"
        perc, col, col_bar = get_volume(cmd_result, right)
        output = output .. colors.title .. "Right" .. cmds.rjust .. col .. perc .. "% " .. col_bar .. cmds.lua_bar:gsub("FN", "echo " .. perc) .. "\n"
    else
        output = output .. colors.title .. "Left" .. cmds.rjust .. colors.critical .. "- - -\n"
        output = output .. colors.title .. "Right" .. cmds.rjust .. colors.critical .. "- - -\n"
    end

    return output
end


local cmd_result = utils.run_command(cmd)
local output = parse_result(cmd_result)

io.write(output)
