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


function get_updates_info(cmd_result)
    -- parses the output of df -h command for the specified device and
    -- forms the output string that conky can parse in its turn

    local title = "Updates "

    local _, count = cmd_result:gsub('\n', '\n')
    if count == nil then
        return colors.title .. title .. rjust .. "  - - -\n"
    end

    local color = colors.normal
    if count > 0 then
    	color = colors.warning
    end

    return colors.title .. title .. rjust .. color ..  tostring(count) .. "\n"
end


local cmd_result = run_command("checkupdates")

local output = get_updates_info(cmd_result)
io.write(output)
