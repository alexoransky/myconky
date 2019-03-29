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

    local col = colors.warning_bar
    if status == "on" then
        col = colors.normal_bar
    end

    return tonumber(perc), col
end

function parse_result(cmd_result)
    local left_col = colors.warning_bar
    local right_col = colors.warning_bar
    local left_perc = "0"
    local right_perc = "0"
    if cmd_result ~= "" then
        left_perc, left_col = get_volume(cmd_result, left)
        right_perc, right_col = get_volume(cmd_result, right)
    end

    local output = ""
    output = output .. colors.text .. "Left" .. colors.normal .. cmds.rjust .. left_perc .. "% " .. left_col .. cmds.lua_bar:gsub("FN", "echo " .. left_perc) .. "\n"
    output = output .. colors.text .. "Right" .. colors.normal .. cmds.rjust .. right_perc .. "% " .. right_col .. cmds.lua_bar:gsub("FN", "echo " .. right_perc) .. "\n"

    return output
end


local cmd_result = utils.run_command(cmd)
local output = parse_result(cmd_result)

io.write(output)
