--
-- Alex Oransky, 2018
-- https://github.com/alexoransky/myconky
--

nd = {}

local cjson = require "cjson.safe"

nd.cmd_tmpl = "curl -s -X GET \"http://IP_ADDR/netdata/api/v1/data?chart=CMD_NAME&after=-1&before=0&points=20&group=average&gtime=0&format=json&options=seconds,jsonwrap\""

local latest_values = "latest_values"


function nd.cmd(ip_addr, cmd)
    local cmd = nd.cmd_tmpl:gsub("CMD_NAME", cmd)

    return cmd:gsub("IP_ADDR", ip_addr)
end


function nd.get_values(s)
    local cr = cjson.decode(s)
    if cr == nil then
        return nil
    end

    return cr[latest_values]
end


function nd.get_value(s, n)
    local cr = cjson.decode(s)
    if cr == nil then
        return nil
    end

    local vals = cr[latest_values]
    if vals ~= nil then
        local val = vals[n]
        if val ~= nil then
            return val
        end
    end

    return nil
end


return nd
