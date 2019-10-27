#!/usr/bin/env lua
--
-- Alex Oransky, 2018
-- https://github.com/alexoransky/myconky
--

--
-- The script outputs a conky command to print the raw METAR for the specified
-- station ICAO ID.
--
-- Usage:
--   ${execpi <TIME_PERIOD> <PATH>/metar.lua <ICAO>}:
--   e.g.
--   ${execpi 60 ~/.config/conky/scripts/metar.lua eno1 KMLB}
--
-- Output:
-- KMLB 241953Z 27011G18KT 10SM CLR 30/17 A2978 RMK AO2 SLP082 T03000172
--

require "./utils/colors"
require "./utils/cmds"
require "./utils/utils"


function parse_metar(cmd_result, icao)
    local ref = cmd_result:find(icao)
    if ref == nil then
        return icao .. cmds.rjust .. colors.warning .. "- - -\n"
    end

    output = colors.normal

    -- parse the main part, skip remarks
    -- pack 6 words in one line
    words = utils.split_str(cmd_result:sub(ref+5, -4))
    local base = 0
    local idx = base
    while true do
        for i = 1, 6 do
            idx = base + i
            if words[idx] == nil or words[idx] == "RMK" then
                break
            end
            output = output .. words[idx] .. "  "
        end
        if words[idx] == nil or words[idx] == "RMK" then
            break
        end
        base = base + 6
        output = output .. "\n"
    end

    return output
end


local cmd = "curl " .. cmds.metar_src

local output = ""
local icao = arg[1]
if icao ~= nil then
    cmd = cmd .. icao .. ".TXT"
    local cmd_result = utils.run_command(cmd)

    output = parse_metar(cmd_result, icao)
end

io.write(output)
