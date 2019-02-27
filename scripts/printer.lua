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

local cjson = require "cjson.safe"

warning = "moni moniWarning"
level = "class=\"tonerremain\" height=\""

function save_printer_file(cmd_result)
    local title = "\"Status\""
    local status = "\"Ok\""

    if cmd_result == "" then
        status = "- - -"
    else
        local ref = cmd_result:find(warning)
        if ref ~= nil then
            status = "\"Warning\""
        end
    end
    local output = "{" .. title .. ": " ..  status .. "}"

    -- find the remaining toner string
    local ref = cmd_result:find(level)
    if ref ~= nil then
        -- get level
        local p1 = cmd_result:find("t=\"", ref)
        local p2 = cmd_result:find("\"", p1+3)
        local level_str = cmd_result:sub(p1+3, p2-1)
        local level = tonumber(level_str)
        if level ~= nil then
            local perc = level*2   -- height is defined in pix out of 50 max

            -- get toner color
            local p1 = cmd_result:find(" alt=\"", ref-20)
            local p2 = cmd_result:find("\"", p1+6)
            local toner = cmd_result:sub(p1+6, p2-1)

            output = "{\"" .. toner .. "\": " .. perc .. "}"
        end
    end

    s = utils.beautify(output)
    utils.write_to_file(utils.printer_file, s, true)
end

function read_printer_file()
    local toners = cjson.decode(utils.read_file(utils.printer_file))
    if toners == nil then
        return colors.normal .. "Status" .. cmds.rjust .. colors.critical .. "- - -" .. "\n"
    end

    local output = ""
    for toner, perc_str in pairs(toners) do
        local perc = tonumber(perc_str)
        if perc == nil then
            local status = "Ok"
            local color = colors.normal

            local ref = perc_str:find(warning)
            if ref ~= nil then
                status = "Warning"
                color = colors.warning
            end
            output = output .. colors.normal .. toner .. cmds.rjust .. color .. status .. "\n"
        else
            perc = utils.round(perc)
            local col, cb = colors.define(100-perc)
            output = output .. col .. toner .. cmds.rjust .. col .. perc .. "% " .. cb .. cmds.lua_bar:gsub("FN", "echo " .. perc) .. "\n"
        end
    end
    return output
end


printer_status_url = "http://<IP>/general/status.html"
local cmd = "curl  -s -X GET " .. printer_status_url

local output = ""
local ip = arg[1]
if ip ~= nil then
    if (not utils.file_exists(utils.printer_file)) and (utils.file_exists(utils.printer_file_save)) then
        utils.copy_file(utils.printer_file_save, utils.printer_file)
    else
        cmd = cmd:gsub("<IP>", ip)
        local cmd_result = utils.run_command(cmd)
        save_printer_file(cmd_result)
    end
    output = read_printer_file()
end

io.write(output)
