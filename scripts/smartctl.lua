#!/usr/bin/env lua

--
-- The script outputs conky commands to print the smartctl info (drive op age
-- and the last test) for the specified disk.
--
-- Usage:
--   ${execpi <TIME_PERIOD> <PATH>/smartctl.lua <DEVICE>}:
--   ${execpi 3600 ~/.config/conky/scripts/smartctl.lua sda}
--
-- Output:
-- Disk  3m 2d 25h   3h ago: TEST OK
--

require "colors"
require "cmds"
require "utils"


function get_disk_on(cmd_result, dev_id)
    -- parse the age
    local p1 = cmd_result:find("Power_On_Hours")
    if p1 == nil then
        return colors.title .. dev_id .. cmds.rjust .. "  - - -\n"
    end

    local p2 = cmd_result:find("\n", p1)
    local temp = cmd_result:sub(p1 + 14, p2-1)
    local words = utils.split_str(temp)

    local age_hr = tonumber(words[8])
    local age = utils.hr_to_mdh(age_hr)

    return colors.title .. dev_id .. cmds.tab40 .. colors.text .. age, age_hr
end

function get_disk_test(cmd_result, age)
    -- parse the age
    local ref = cmd_result:find("Num  Test_Description")
    if ref == nil then
        return colors.title .. "Test " .. cmds.rjust .. "  - - -\n"
    end

    -- find first records for the short and the long tests
    local p1 = cmd_result:find("Short offline", ref)
    local short = p1
    local p1 = cmd_result:find("Extended offline", ref)
    local long = p1
    if short == nil and long == nil then
        return colors.title .. "Test " .. cmds.rjust .. "  - - -\n"
    end

    -- find the latest test, newest first
    local test = "Long "
    if long == nil or short < long then
        p1 = short
        test = "Short "
    end

    -- find the test result and the age of the disk when it was performed
    local p2 = cmd_result:find("\n", p1)
    local temp = cmd_result:sub(p1 + 17, p2-1)
    local words = utils.split_str(temp)

    local status = "FAIL"
    local color = colors.critical

    if words[1] == "Completed" and words[2] == "without" and words[3] == "error" then
        status = "OK"
        color = colors.normal
    end

    -- determine the color based on the test age
    local test_hr = tonumber(words[5])
    local t_diff = age - test_hr
    local color_age = colors.normal
    if t_diff < 0 or t_diff > 24 then
        color_age = colors.warning
    end

    local test_hr_str = ""
    if t_diff > 0 then
        test_hr_str = tostring(t_diff) .. "h ago   "
    end

    return cmds.rjust .. color_age .. test_hr_str .. color .. test .. status .. "\n"
end

local dev_id = "/dev/" .. arg[1]
local cmd = "smartctl -a " .. dev_id
local result = utils.run_command(cmd)

local output, age = get_disk_on(result, dev_id)
output = output .. get_disk_test(result, age)
io.write(output)
