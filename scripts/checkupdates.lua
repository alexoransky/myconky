#!/usr/bin/env lua
--
-- Alex Oransky, 2018
-- https://github.com/alexoransky/myconky
--

--
-- The script outputs a conky command to print the imformation for the
-- available package updates.
--
-- Usage:
--   ${execpi <TIME_PERIOD> <PATH>/checkupdates.lua [<N>]}:
--   <N> will print info only on first N updates
--   ${execpi 3600 ~/.config/conky/scripts/checkupdates.lua 3}
--
-- Output:
-- Total                     3:
--           pkg 1.1.0 -> 1.1.1
--           ...
--

require "colors"
require "cmds"
require "utils"


function get_pkgs(cmd_result, max_cnt)
    -- parses the output of df -h command for the specified device and
    -- forms the output string that conky can parse in its turn
    if cmd_result == nil or cmd_result == "" then
        return ""
    end

    local temp = ""
    local p1 = utils.find_substr(cmd_result, "\n", max_cnt)
    if p1 == nil then
        temp = cmd_result
    else
        temp = cmd_result:sub(1, p1)
    end

    -- split into lines and right-justify
    local output = colors.title .. "PACKAGE" .. cmds.tab(55) .. "OLD" ..
                   cmds.tab(102) .. "NEW\n" .. colors.normal
    for line in temp:gmatch("[^\r\n]+") do
        local words = utils.split_str(line)
        output = output .. words[1] .. cmds.tab(55) .. words[2] .. cmds.tab(102) .. words[4] .. "\n"
     end

    return output
end


function get_updates_info(cmd_result, max_cnt)
    -- parses the output of df -h command for the specified device and
    -- forms the output string that conky can parse in its turn

    if max_cnt == nil then max_cnt = 0 end

    local title = "Total "

    local count = utils.count_substr(cmd_result, '\n')
    if count == nil then
        return colors.title .. title .. cmds.rjust .. "  - - -\n"
    end

    local color, cb = colors.define(count, 0, max_cnt)

    local first_line = colors.title .. title .. cmds.rjust .. color ..  tostring(count)
    if (count < 1) or (max_cnt < 1) then
        return first_line .. " \n"
    end

    return first_line .. ":\n" .. get_pkgs(cmd_result, math.min(max_cnt, count))
end


local cmd_result = utils.run_command("checkupdates")
local max_cnt = tonumber(arg[1])

local output = get_updates_info(cmd_result, max_cnt)
io.write(output)
