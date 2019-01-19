--
-- Alex Oransky, 2018
-- https://github.com/alexoransky/myconky
--

colors = {}

colors.text = "${color1}"
colors.title = "${color2}"
colors.section = "${color3}"
colors.normal = "${color6}"
colors.normal_bar = "${color4}"
colors.warning = "${color8}"
colors.warning_bar = "${color8}"
colors.critical = "${color9}"
colors.critical_bar = "${color9}"

local HIGH = 75
local CRITICAL = 90

function colors.define(val, high, critical)
    if high == nil then
        high = HIGH
    end

    if critical == nil then
        critical = CRITICAL
    end

    local color_val = colors.normal
    local color_bar = colors.normal_bar
    if val > critical then
    	color_val = colors.critical
        color_bar = colors.critical_bar
    elseif val > high then
    	color_val = colors.warning
        color_bar = colors.warning_bar
    end

    return color_val, color_bar
end

return colors
