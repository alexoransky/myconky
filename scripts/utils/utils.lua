--
-- Alex Oransky, 2018
-- https://github.com/alexoransky/myconky
--

utils = {}

local cjson = require "cjson.safe"

utils.xfer_path_disk = "/mnt/ramdisk/conky_data_disk"
utils.xfer_path_network = "/mnt/ramdisk/conky_data_network"

-- state files
utils.hosts_file_save = "/home/alex/.config/conky/hosts.txt"
utils.hosts_file = "/mnt/ramdisk/hosts.txt"
utils.printer_file_save = "/home/alex/.config/conky/printer.txt"
utils.printer_file = "/mnt/ramdisk/printer.txt"

--
-- the following is used for lua_scripts.lua
-- and in netdata modules
-- disk_traffic.lua
utils.DATA_IN       = 1  -- conky_load_data_in()
utils.DATA_OUT      = 2  -- conky_load_data_out()
-- network_traffic.lua
utils.DATA_RECEIVED = 1  -- conky_load_data_received()
utils.DATA_SENT     = 2  -- conky_load_data_sent()

local xfer_val = {}
--

function utils.read_file(fpath)
    -- check if the file exists
    local f = io.open(fpath, "rb")
    if f == nil then
        return nil
    end
    f:close()

    f = assert(io.open(fpath, "rb"))
    local content = f:read("*all")
    f:close()
    return content
end

-- reads a line from file "fpath" if the line contains "item"
function utils.read_from_file(fpath, item)
    -- check if the file exists
    local f = io.open(fpath, "rb")
    if f == nil then
        return nil
    end
    f:close()

    for line in io.lines(fpath) do
        local ref = line:find(item)
        if ref ~= nil then
            return line
        end
    end

    return nil
end


-- writes an item to file "fpath"
function utils.write_to_file(fpath, item, overwite)
    local mode = "a"
    if overwite ~= nil then
        if overwite then
            mode = "wb"
        end
    end

    local f = io.open(fpath, mode)
    if f == nil then
        return false
    end

    if type(item) == "table" then
        for i = 1, #item do
            f:write(item[i] .. "\n")
        end
    else
        f:write(item)
    end

    f:flush()
    f:close()

    return true
end


-- returns true if file exists and is readable
function utils.file_exists(fpath)
    local f = io.open(fpath, "rb")
    if f then
        f:close()
    end
    return f ~= nil
end


function utils.copy_file(inf, outf)
    infile = io.open(inf, "r")
    instr = infile:read("*a")
    infile:close()

    outfile = io.open(outf, "w")
    outfile:write(instr)
    outfile:close()
end


function utils.beautify(json)
    local s = json:gsub("{", "{\n")
    s = s:gsub("}", "\n}")
    s = s:gsub(",", ",\n")
    return s
end


-- runs the shell command "cmd" and returns the stdio output
function utils.run_command(cmd)
    local handle = io.popen(cmd)
    local output = handle:read("*a")
    handle:close()

    return output
end


-- finds "num"'th substring "str" in string "str"
-- returns its position
function utils.find_substr(str, substr, num)
    local i = 1
    local ref = 1
    local p1 = 1
    local p2 = 1
    while i <= num do
        p1 = str:find(substr, ref)
        if p1 == nil or p1 == p2 then
            return nil
        end
        i = i + 1
        p2 = p1
        ref = p1+1
    end

    return p1
end


-- reverse find
function utils.rfind(str, substr)
    return str:match(".*()" .. substr)
end


-- counts substring "substr" in string "str"
function utils.count_substr(str, substr)
    local _, cnt = str:gsub(substr, substr)
    return cnt
end


-- remove leading whitespace from string.
-- http://en.wikipedia.org/wiki/Trim_(programming)
function utils.ltrim(s)
  return (s:gsub("^%s*", ""))
end


-- splits the string into words on spaces
function utils.split_str(s)
    local words = {}
    for word in s:gmatch("%S+") do
        table.insert(words, word)
    end
    return words
end


function utils.split_line(s)
    local lines = {}
    for line in s:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end
    return lines
end


function utils.hr_to_mdh(hr)
    local m = math.floor(hr / 744)
    local d = math.floor((hr - 744*m) / 24)
    local h = math.floor(math.fmod(hr, 24))

    return m .. "m " .. d .. "d " .. h .. "h"
end


-- time intervals in seconds
local one_min = 60
local one_hour = one_min * 60
local one_day = one_hour * 24
local one_month = one_day * 30
local one_year = one_month * 12


function utils.intdiv(a, b)
    q = math.floor(a / b)
    r = a - q * b
    return q, r
end


function utils.sec_to_ymdhms(sec)
    local y, m, d, h, min, s
    local rem = math.floor(sec)

    y, rem = utils.intdiv(rem, one_year)
    m, rem = utils.intdiv(rem, one_month)
    d, rem = utils.intdiv(rem, one_day)
    h, rem = utils.intdiv(rem, one_hour)
    min, s = utils.intdiv(rem, one_min)

    return y, m, d, h, min, s
end


function utils.sec_to_dhms(sec)
    local d, h, m, s
    local rem = sec

    d, rem = utils.intdiv(rem, one_day)
    h, rem = utils.intdiv(rem, one_hour)
    m, s = utils.intdiv(rem, one_min)

    return d, h, m, s
end


function utils.sec_to_human(sec)
    local y, m, d, h, min, s = utils.sec_to_ymdhms(sec)

    if y > 0 then
        return y .. "y " .. m .. "m " .. d .. "d " .. h .. "h " .. min .. "m " .. s .. "s"
    end

    if m > 0 then
        return m .. "m " .. d .. "d " .. h .. "h " .. min .. "m " .. s .. "s"
    end

    if d > 0 then
        return d .. "d " .. h .. "h " .. min .. "m " .. s .. "s"
    end

    if h > 0 then
        return h .. "h " .. min .. "m " .. s .. "s"
    end

    if min > 0 then
        return min .. "m " .. s .. "s"
    end

    return s .. "s"
end


function utils.time_since(epoch)
    local curr_time = os.time()
    local sec = curr_time - epoch
    local d, h, m, s = utils.sec_to_dhms(sec)

    if d > 0 then
        if h > 0 then
            return d .. "d " .. h .. "h", sec
        end
        return d .. "d ", sec
    end
    if h > 0 then
        if m > 0 then
            return h .. "h " .. m .. "m", sec
        end
        return h .. "h ", sec
    end
    if m > 0 then
        return m .. "m", sec
    end

    return s .. "s", sec
end


-- parses the output of "ping" command
-- return 0 if failed, other number of ms
function utils.parse_ping_return(cmd_result)
    local ref = cmd_result:find("rtt min/avg/max/mdev =")
    if ref == nil then
        return 0
    end

    local p1 = cmd_result:find("/", ref+22)
    local p2 = cmd_result:find("/", p1+2)
    time = utils.round(tonumber(cmd_result:sub(p1+1, p2-1)), 2)

    return time
end


-- parses the output of "avahi0resolve -a" command, e.g.
-- 192.168.0.100    NAS.local
function utils.parse_avahi_resolve(cmd_result)
    local p = cmd_result:find("Failed to resolve address")
    if p ~= nil then
        return nil
    end

    local ref = cmd_result:find("\t")
    if ref == nil then
        return nil
    end

    local ip = cmd_result:sub(1, ref-1)

    local host = cmd_result:sub(ref+1)
    p = host:find(".local")
    if p ~= nil then
        host = host:sub(1, p-1)
    end

    return ip, host
end


function utils.round(num, dec)
    if dec == nil then
        dec = 0
    end

    if dec == 0 then
        return math.floor(num + 0.5)
    end

    local mult = 10^dec
    return math.floor(num*mult + 0.5) / mult
end


function utils.store_data(key, val, xfer_path)
    xfer_val[key] = val
    local output = cjson.encode(xfer_val)

    utils.write_to_file(xfer_path, output, true)
end


function utils.load_data(key, xfer_path)
    local c = utils.read_file(xfer_path)

    local cr = cjson.decode(c)
    if cr == nil then
        return nil
    end

    local v = cr[key]
    return v
end


-- from https://stackoverflow.com/questions/15706270/sort-a-table-in-lua
function utils.spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function utils.sort_ips(t, ip_a, ip_b)
    local p1 = utils.rfind(ip_a, "%.")
    local p2 = utils.rfind(ip_b, "%.")

    ip1 = tonumber(ip_a:sub(p1+1))
    ip2 = tonumber(ip_b:sub(p2+1))

    return ip1 < ip2
end

return utils
