--
-- Alex Oransky, 2018
-- https://github.com/alexoransky/myconky
--

nd = {}

local cjson = require "cjson.safe"

nd.cmd_tmpl = "curl -s -X GET \"http://IP_ADDR/netdata/api/v1/data?chart=CMD_NAME&after=-1&format=json\""

local data = "data"


function nd.cmd(ip_addr, cmd)
    local cmd = nd.cmd_tmpl:gsub("CMD_NAME", cmd)

    return cmd:gsub("IP_ADDR", ip_addr)
end


function nd.get_values(s)
    local cr = cjson.decode(s)
    if cr == nil then
        return nil
    end

    local d = cr[data]
    if d == nil then
        return nil
    end

    return d[1]
end


function nd.get_value(s, n)
    local cr = cjson.decode(s)
    if cr == nil then
        return nil
    end

    local d = cr[data]
    if d == nil then
        return nil
    end

    local val = d[1]
    if val == nil then
        return nil
    end

    return val[n]
end


return nd
