#!/usr/bin/env lua
--
-- Alex Oransky, 2018
-- https://github.com/alexoransky/myconky
--

--
-- The script outputs a conky command to display speedtest results.
--
-- Usage:
--   ${execpi <TIME_PERIOD> <PATH>/speedtest.lua}:
--   e.g. for eno1 and wlan0:
--   ${execp ~/.config/conky/scripts/speedtest.lua}
--
-- Nite:
--   The script requires speedtest-cli installed:
--   pip install speedtest-cli
--

require "colors"
require "fonts"
require "cmds"
require "utils"


PING = "Ping: "
DOWNLOAD = "Download: "
UPLOAD = "Upload: "
MS = " ms"
MBITS = " Mbit/s"

function get_data(s, param_str, unit_str)
	local ref = 0
	local val = ""
    local p1 = 0
    local p2 = 0

	ref = s:find(param_str)
    if ref == nil then
        return nil
    end
    p1 = s:find(": ", ref)
	p2 = s:find(unit_str, p1)
	val = s:sub(p1+2, p2-1)

	return tonumber(val)
end


function parse_result(result)
    local ping = get_data(result, PING, MS)
    local dn = get_data(result, DOWNLOAD, MBITS)
    local up = get_data(result, UPLOAD, MBITS)

    if ping == nil then
        return colors.critical .. fonts.symbols .. "▼  " .. fonts.text .. "- - -" ..
               cmds.rjust .. "- - -" .. fonts.symbols .. "  ▲" .. fonts.text .. "\n"
    end

    local color_ping, cb = colors.define(ping, 50.0, 100.0)
    local color_dn = colors.critical
    local color_up = colors.critical
    if dn > 0 then
        color_dn, cb = colors.define(1/dn, 1/80.0, 1/50.0)
    end
    if up > 0 then
        color_up, cb = colors.define(1/up, 1/8.0, 1/5.0)
    end

    local output = color_dn .. fonts.symbols .. "▼  " .. fonts.text .. dn .. " M" ..
                   cmds.tab(56).. color_ping .. ping .. " ms" ..
                   cmds.rjust .. color_up .. up .. " M" ..
                   fonts.symbols .. "  ▲" .. fonts.text .. "\n"
    return output
end


local output = ""
local cmd_result = utils.run_command("speedtest-cli --simple")
local output = parse_result(cmd_result)
io.write(output)
