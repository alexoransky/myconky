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

require "./utils/colors"
require "./utils/cmds"
require "./utils/utils"
require "./utils/files"

local cjson = require "cjson.safe"

local cmd = "curl -s -X GET http://<IP>/general/status.html"

local ok = "moni moniOk"
local warning = "moni moniWarning"
local level = "class=\"tonerremain\" height=\""
local status_line = false  -- set to true when there is more than one toner

function save_printer_file(cmd_result)
    local status = "- - -"
    if cmd_result ~= "" then
        local ref = cmd_result:find(ok)
        if ref ~= nil then
            local p1 = cmd_result:find("Ok\">", ref)
            local p2 = cmd_result:find("</span>", p1+3)
            status = cmd_result:sub(p1+4, p2-1)
        end
        local ref = cmd_result:find(warning)
        if ref ~= nil then
            status = "Warning"
        end
    end
    local output = "{\"Status\": \"" ..  status .. "\","

    -- find the remaining toner string
    local ref = cmd_result:find(level)
    if ref ~= nil then
        -- get level
        local p1 = cmd_result:find("t=\"", ref)
        local p2 = cmd_result:find("\"", p1+3)
        local level_str = cmd_result:sub(p1+3, p2-1)
        local level = tonumber(level_str)
        if level ~= nil then
            local perc = utils.round(level*100/56)   -- height is defined in pix out of 56 max

            -- get toner color
            local p1 = cmd_result:find(" alt=\"", ref-20)
            local p2 = cmd_result:find("\"", p1+6)
            local toner = cmd_result:sub(p1+6, p2-1)

            output = output .. "\"" .. toner .. "\": " .. perc .. "}"
        end
    end

    s = utils.beautify(output)
    utils.write_to_file(files.temp_path .. files.printer, s, true)
end

function read_printer_file()
    local toners = cjson.decode(utils.read_file(files.temp_path .. files.printer))
    if toners == nil then
        return colors.normal .. "Status" .. cmds.rjust .. colors.critical .. "- - -" .. "\n"
    end

    local output = ""
    local status_output = ""
    local status = ""
    local color = colors.normal
    for toner, perc_str in pairs(toners) do
        -- try to read the percentage
        -- if cannot convert to a number, assume it is a status
        local perc = tonumber(perc_str)
        if perc == nil then
            status = perc_str
            color = colors.normal

            local ref = perc_str:find(warning)
            if ref ~= nil then
                status = "Warning"
                color = colors.warning
            end
            status_output = colors.normal .. toner .. cmds.rjust .. color .. status .. "\n"
        else
            perc = utils.round(perc)
            local col, cb = colors.define(100-perc)
            if status_line then
                output = output .. col .. toner .. cmds.rjust .. col .. perc .. "% " .. cb .. cmds.lua_bar:gsub("FN", "echo " .. perc) .. "\n"
            else
                output = cmds.rjust .. col .. perc .. "% " .. cb .. cmds.lua_bar:gsub("FN", "echo " .. perc) .. "\n"
            end
        end
    end

    if status_line then
        output = status_output .. output
    else
        output = color .. status .. output
    end

    return output
end


local output = ""
local ip = arg[1]
if ip ~= nil then
    -- if running for the first time, copy the file from HDD to RAM disk
    -- if not, run the command and save the result into a file
    if not files.restore_file(files.printer) then
        cmd = cmd:gsub("<IP>", ip)
        local cmd_result = utils.run_command(cmd)
        save_printer_file(cmd_result)
    end
    -- read the file from the RAM disk, process it and display the result
    output = read_printer_file()
end

io.write(output)
