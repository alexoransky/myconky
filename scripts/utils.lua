--
-- Alex Oransky, 2018
-- https://github.com/alexoransky/myconky
--

utils = {}

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


function utils.hr_to_mdh(hr)
    local m = math.floor(hr / 744)
    local d = math.floor((hr - 744*m) / 24)
    local h = math.floor(math.fmod(hr, 24))

    return m .. "m " .. d .. "d " .. h .. "h"
end


return utils
