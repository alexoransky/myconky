#!/usr/bin/env lua

--[[
local command = "checkupdates | wc -l"

local handle = io.popen(command)
local result = handle:read("*a")
handle:close()
--]]

-- parse ${user_number}
function conky_user_number(arg)
	local color = "${color6}"
	if tonumber(arg) > 1 then
		color = "${color8}"
	end

	io.write(arg)
	return color .. arg
end
