#!/usr/bin/env lua

--local colors = require("colors")
colors = {}
colors.title = "${color2}"
colors.text  = "${color1}"
colors.normal = "${color6}"
colors.warning = "${color8}"
colors.critical = "${color9}"

-- conky commands
rjust =  "${alignr}"
user_number = "${user_number}"
user_names = "${user_names}"

-- returns
-- ${color2}Logged In ${alignr}${colorX}${user_number}
function conky_logged_in()
	local user_num = conky_parse(user_number)
	local color = colors.normal
	if tonumber(user_num) > 1 then
		color = colors.warning
	end
	return colors.title .. "Logged In " .. rjust .. color .. user_num .. " :  " .. user_names
end

io.write(conky_sys_info())
