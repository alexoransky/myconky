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

require "./utils/colors"
require "./utils/fonts"
require "./utils/cmds"
require "./utils/utils"
require "./utils/files"
local cjson = require "cjson.safe"

CMD_SIMPLE = "speedtest-cli --simple"
CMD_JSON = "speedtest-cli --json"
FORMAT_SIMPLE = "-s"

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


function parse_result(result, format)
    local ping
    local dn
    local up

    if format == FORMAT_SIMPLE then
        ping = get_data(result, PING, MS)
        dn = get_data(result, DOWNLOAD, MBITS)
        up = get_data(result, UPLOAD, MBITS)
    else
        local data = cjson.decode(result)
        if data == nil then
            data = {}
        end
        ping = utils.round(data["ping"], 2)
        dn = utils.round(data["download"] / (1000*1000), 2)
        up = utils.round(data["upload"] / (1000*1000), 2)
        ts = data["timestamp"]

        local data_out = {}
        data_out["timestamp"] = ts
        data_out["ping"] = ping
        data_out["download"] = dn
        data_out["upload"] = up
        local out_str = cjson.encode(data_out)
        utils.write_to_file(files.perm_path .. files.speedtest, utils.beautify(out_str)..",\n")
    end

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
local cmd = CMD_JSON
if arg[1] == FORMAT_SIMPLE then
    cmd = CMD_SIMPLE
end
local cmd_result = utils.run_command(cmd)
local output = parse_result(cmd_result, arg[1])
io.write(output)
