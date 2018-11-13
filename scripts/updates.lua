#!/usr/bin/env lua

--
-- The script outputs a conky command to print the imformation for the
-- available package updates.
--
-- Usage:
--   ${execpi <TIME_PERIOD> <PATH>/updates.lua}:
--   ${execpi 3600 ~/.config/conky/scripts/updates.lua}
--
-- Output:
-- Package updates        3
--
-- This script implements the conky command below.
--
--   #${color2}Package updates ${alignr}\
--   #${if_match ${exec checkupdates | wc -l} > 0}${color8}\
--   #${else}${color6}\
--   #${endif}\
--   #${exec checkupdates | wc -l}
--

-- conky colors
--local colors = require("colors")
colors = {}
colors.title = "${color2}"
colors.text  = "${color1}"
colors.normal = "${color6}"
colors.normal_bar = "${color4}"
colors.warning = "${color8}"
colors.critical = "${color9}"

-- conly commands
rjust = "${alignr}"


function run_command(cmd)
    -- runs the specified shell command
    -- and returns the printed output

    local handle = io.popen(cmd)
    local output = handle:read("*a")
    handle:close()

    return output
end


function find_nth(str, substr, cnt)
    local i = 1
    local ref = 1
    local p1 = 1
    local p2 = 1
    while i <= cnt do
        p1 = str:find(substr, ref)
        if p1 == nil or p1 == p2 then
            return nil
        end
        i = i + 1
        p2 = p1
        ref = p1+1
    end

    return p1
end


function get_updates_info(cmd_result, max_cnt)
    -- parses the output of df -h command for the specified device and
    -- forms the output string that conky can parse in its turn
    if cmd_result == nil or cmd_result == "" then
        return ""
    end

    local p1 = find_nth(cmd_result, "\n", max_cnt)
    if p1 == nil then
        return cmd_result
    end

    local output = cmd_result:sub(1, p1)
    return output
end


local cmd_result = run_command("checkupdates")
local max_cnt = tonumber(arg[1])

local output = get_updates_info(cmd_result, max_cnt)
io.write(output)
