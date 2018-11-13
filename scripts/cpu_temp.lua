#!/usr/bin/env lua

--local colors = require("colors")
colors = {}
colors.normal = "${color6}"
colors.warning = "${color8}"
colors.critical = "${color9}"

function run_command(cmd)
    local handle = io.popen(cmd)
    local result = handle:read("*a")
    handle:close()

    return result
end

function get_temp(s, temp_str, high_str, crit_str)
	local ref = 0
	local temp = ""
	local high = ""
    local crit = ""
    local p1 = 0
    local p2 = 0

	ref = s:find(temp_str)
    if ref == nil then
        return nil
    end

    p1 = s:find("+", ref)
	p2 = s:find("C", p1)
	temp = s:sub(p1, p2-3)

    ref = s:find(high_str)
    if ref == nil then
        return nil
    end

	p1 = s:find("+", ref)
	p2 = s:find("C", p1)
	high = s:sub(p1, p2-3)

	ref = s:find(crit_str)
    if ref == nil then
        return nil
    end

	p1 = s:find("+", ref)
	p2 = s:find("C", p1)
	crit = s:sub(p1, p2-3)

	return tonumber(temp), tonumber(high), tonumber(crit)
end

local result = run_command("sensors")
id = "Core " .. arg[1]

t, h, c = get_temp(result, id, "high", "crit")
if t == nil then
    io.write(colors.warning .. "---\n")
    do return end
end

local color = colors.normal
if t > c then
	color = colors.critical
elseif t > h then
	color = colors.warning
end

local output = color .. " +" .. t .. "°C" .. "\n"
io.write(output)
