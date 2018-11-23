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
           colors.title .. "T:  " .. colors.normal ..cmds.metar_temperature:gsub("ICAO", icao) .. " °C   "  ..
           colors.title .. "P:  " .. colors.normal ..cmds.metar_pressure:gsub("ICAO", icao) .. " hPa   "  ..
           colors.title .. "H:  " .. colors.normal ..cmds.metar_humidity:gsub("ICAO", icao) .. " %   "  .. cmds.rjust ..
           colors.title .. "W:  " .. colors.normal ..cmds.metar_wind_dir:gsub("ICAO", icao) .. "  " ..
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

    local output = colors.title .. "NAME" .. cmds.rjust ..
                   "PID       CPU        MEM\n" .. colors.normal
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


-- returns
-- ${color2}RAM: ${tab 38} \
-- ${color1}${memmax} ${alignr}${color6}$memperc%  ${color4}${membar 6, 100}
-- ${color2}Swap: ${tab 38} \
-- ${color1}${swapmax} ${alignr}${color6}$swapperc%  ${color4}${swapbar 6, 100}
function conky_mem_size(swap)
    local mem_used = tonumber(conky_parse(cmds.mem_used))
    local swap_used = tonumber(conky_parse(cmds.swap_used))

	local color = colors.normal
    local color_bar = colors.normal_bar
	if mem_used > 75 then
		color = colors.warning
        color_bar = colors.warning_bar
	end
	local output = colors.title .. "RAM" .. cmds.tab40 .. colors.text ..
                   cmds.mem_total .. cmds.rjust .. color .. mem_used ..
                   "%  " .. color_bar .. cmds.mem_bar

    if swap ~= "-s" or swap_used < 1 and mem_used <= 75 then
        return output
    end

	color = colors.normal
    color_bar = colors.normal_bar
	if swap_used > 75 then
		color = colors.warning
        color_bar = colors.warning_bar
	end

    output = output .. "\n" .. colors.title .. "SWAP" .. cmds.tab40 ..
             colors.text .. cmds.swap_total .. cmds.rjust .. color ..
             swap_used .. "%  " .. color_bar .. cmds.swap_bar

    return output
end
