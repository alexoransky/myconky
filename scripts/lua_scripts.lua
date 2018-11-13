--local colors = require("colors")
colors = {}
colors.normal = "${color6}"
colors.warning = "${color8}"
colors.critical = "${color9}"

function conky_user_number(arg)
	local user_num = conky_parse(arg)
	local color = colors.normal
	if tonumber(user_num) > 1 then
		color = colors.warning
	end
	return color..user_num
end
