#!/usr/bin/env lua

require "colors"
require "fonts"
require "cmds"

--
-- This script contains:
-- 1. Functions that require conky to parse the variable to a value before the
--    value can be used for highlighting.
-- 2. Functions that need to run every cycle.
--
-- This script does not contain functions that require shell commands to run or
-- functions that provide information at a slow rate, such as every our.
-- Those functions are implemented in stand-alone scripts.
--


-- returns
-- ${color2}Logged In ${alignr}${colorX}${user_number}
function conky_logged_in()
	local user_num = conky_parse(cmds.user_number)
	local color = colors.normal
	if tonumber(user_num) > 1 then
		color = colors.warning
	end
	return colors.title .. "Logged In " .. cmds.rjust .. color .. user_num ..
           ":  " .. cmds.user_names
end


-- ${color2}Load$ {alignr}${color6}${loadavg}
-- returns
function conky_loadavg()
    local load = conky_parse(cmds.loadavg)

    local output = colors.title .. "Load " .. cmds.rjust
    for ld in string.gmatch(load, "%S+") do
        avg = tonumber(ld)
        color = colors.normal
        if avg > 5.0 then
            color = colors.critical
        elseif avg > 1.0 then
            color = colors.warning
        end
        output = output .. " " .. color .. tostring(string.format("%.2f", avg))
    end

    return output
end


-- returns
-- ${color2}Uptime ${alignr}${color1} $uptime
function conky_uptime()
    return colors.title .. "Uptime " .. cmds.rjust .. colors.text .. cmds.uptime
end


-- returns
-- ${color2}UTC ${alignr}${color1}$utime
function conky_utc()
    return colors.title .. "UTC " .. cmds.rjust .. colors.text .. cmds.utc
end

-- returns
-- ${color3}${font Roboto:size=9:weight:bold}<TITLE> ${hr 2}
-- ${font Roboto:size=9:weight:regular}\
function conky_section(section)
    return colors.section .. fonts.section .. section .. " " .. cmds.line ..
           fonts.text .. "\\"
end


-- returns
--${color7}${cpugraph 20,278 color7 ff0000 -t}
function conky_cpu_graph()
    return colors.normal_bar .. cmds.cpu_gr
end


-- returns
-- ${color2}KMLB \
-- ${alignr}${color6}${weather http://tgftp.nws.noaa.gov/data/observations/metar/stations/ kmlb last_update} UTC
-- ${weather http://tgftp.nws.noaa.gov/data/observations/metar/stations/ kmlb cloud_cover} \
-- ${alignr}${color6}${weather http://tgftp.nws.noaa.gov/data/observations/metar/stations/ kmlb weather}
-- T: ${weather http://tgftp.nws.noaa.gov/data/observations/metar/stations/ kmlb temperature} °C   \
-- P: ${weather http://tgftp.nws.noaa.gov/data/observations/metar/stations/ kmlb pressure} hPa   \
-- H: ${weather http://tgftp.nws.noaa.gov/data/observations/metar/stations/ kmlb humidity}%   \
-- ${alignr}W: ${weather http://tgftp.nws.noaa.gov/data/observations/metar/stations/ kmlb wind_dir}  \
-- ${weather http://tgftp.nws.noaa.gov/data/observations/metar/stations/ kmlb wind_speed} km/h
function conky_metar(icao)
    return colors.title .. icao .. cmds.rjust .. colors.normal ..
           cmds.metar_time:gsub("ICAO", icao) .. " UTC\n" ..
           cmds.metar_cloud_cover:gsub("ICAO", icao) .. cmds.rjust ..
           colors.warning .. cmds.metar_weather:gsub("ICAO", icao) .. colors.normal .. "\n" ..
           "T:  " .. cmds.metar_temperature:gsub("ICAO", icao) .. " °C   "  ..
           "P:  " .. cmds.metar_pressure:gsub("ICAO", icao) .. "  hPa      "  ..
           "H:  " .. cmds.metar_humidity:gsub("ICAO", icao) .. " %   "  .. cmds.rjust ..
           "W:  " .. cmds.metar_wind_dir:gsub("ICAO", icao) .. "  " ..
           cmds.metar_wind_speed:gsub("ICAO", icao) .. " km/h"
end


-- returns
-- ${color3}${font Roboto:size=9:weight:bold}NAME${alignr}PID       CPU        MEM
-- ${color6}${font Roboto:size=9:weight:regular}\
-- ${top name 1}${alignr}${color6}${top pid 1}  ${top cpu 1}%  ${top mem 1}%
-- ${top name 2}${alignr}${color6}${top pid 2}  ${top cpu 2}%  ${top mem 2}%
-- ${top name 3}${alignr}${color6}${top pid 3}  ${top cpu 3}%  ${top mem 3}%
-- ${top name 4}${alignr}${color6}${top pid 4}  ${top cpu 4}%  ${top mem 4}%
-- ${top name 5}${alignr}${color6}${top pid 5}  ${top cpu 5}%  ${top mem 5}%
function conky_ps(total)
    if total == nil then
        return "\\"
    end

    local cnt = tonumber(total)
    if cnt < 1 then
        return "\\"
    end

    local output = colors.title .. "NAMES" .. cmds.rjust ..
                   "PID       CPU        MEM\n" .. colors.normal .. fonts.text
    for i = 1, cnt do
        output = output .. cmds.top_name:gsub("X", i) .. cmds.rjust ..
                 cmds.top_pid:gsub("X", i) .. "  " ..
                 cmds.top_cpu:gsub("X", i) .. "%  " .. cmds.top_mem:gsub("X", i) .. "%"
        if i ~= cnt then
            output = output .. "\n"
        end
    end

    return output
end

-- returns
-- ${color2}Total P/T ${alignr}${color1}${processes} / ${threads}
function conky_processes_treads()
    return colors.title .. "Total P/T " .. cmds.rjust .. colors.normal ..
           cmds.processes .. " / " .. cmds.threads
end
