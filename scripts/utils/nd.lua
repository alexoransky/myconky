--
-- Alex Oransky, 2018
-- https://github.com/alexoransky/myconky
--

nd = {}

local cjson = require "cjson.safe"

nd.cmd_tmpl = "curl -s -X GET \"http://IP_ADDR/netdata/api/v1/data?chart=CMD_NAME&after=-1&format=json\""
nd.cmd_stream_tmpl = "curl -s -X GET \"http://127.0.0.1:19999/host/HOST_NAME/api/v1/data?chart=CMD_NAME&after=-1&format=json\""

local data = "data"


function nd.cmd(ip_addr, cmd)
    -- if the host name is supplied, try to use streamed data to the master
    -- if the IP address is supplied, try to fetch the data from that IP
    local ch = ip_addr:sub(1, 1)
    n = tonumber(ch)
    if n == nil then
        cmd = nd.cmd_stream_tmpl:gsub("CMD_NAME", cmd)
        cmd = cmd:gsub("HOST_NAME", ip_addr)
    else
        cmd = nd.cmd_tmpl:gsub("CMD_NAME", cmd)
        cmd = cmd:gsub("IP_ADDR", ip_addr)
    end

    return cmd
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
