#!/usr/bin/env lua
--
-- Alex Oransky, 2019
-- https://github.com/alexoransky/myconky
--

--
-- The script outputs a conky command to printdiscovered hosts on a given
-- network range of addresses.
--
-- Usage:
--   ${execpi <TIME_PERIOD> <PATH>/netdiscover.lua <address/CIDR netmask> [-m | -p]:
-- -m to display MAC addresses
-- -p to display ping time
--   e.g.
--   ${execpi 600 ~/.config/conky/scripts/netdiscover.lua 192.168.0.0/24}
--
-- See http://jodies.de/ipcalc to define the netmask.
--
-- Output:
-- 192.168.0.1  aa.bb.cc.dd.ee.ff  Router
-- 192.168.0.10 xx.xx.xx.xx.xx.xx  PC_1
--
-- Notes:
-- Currently supports nmap, netdiscover and avahi-resolve.
--


require "./utils/colors"
require "./utils/cmds"
require "./utils/utils"
local cjson = require "cjson.safe"

nmap_scan_report = "Nmap scan report for "

local cmd_nmap = "nmap -sn NETWORK"
local cmd_netdiscover = "netdiscover -r NETWORK -S -P -N"
local cmd_ping = "ping -i 0.2 -c 5 -q "
local cmd_avahi = "avahi-resolve -a "
local cmd_ifconfig = "ifconfig -a"


function discover_hosts(network)
    -- discovers hosts using nmap
    -- and updates hosts.txt file

    local cmd = cmd_nmap:gsub("NETWORK", network)
    local cmd_result = utils.run_command(cmd)

    local hosts = cjson.decode(utils.read_file(utils.hosts_file))
    if hosts == nil then
        hosts = {}
    else
        for ip, h in pairs(hosts) do
            h["discovered"] = false
        end
    end

    local new_ip
    local found = false
    for _, line in pairs(utils.split_line(cmd_result)) do
        local p1 = line:find(nmap_scan_report)
        if p1 ~= nil then
            new_ip = line:sub(p1 + #nmap_scan_report, -1)
            found = false
            for ip, h in pairs(hosts) do
                if ip == new_ip then
                    h["discovered"] = true
                    found = true
                end
            end
            if not found then
                local info = {}
                info["discovered"] = true
                info["mac_read"] = false
                info["name_resolved"] = false
                info["name"] = ""
                info["mac"] = ""
                info["ping_time"] = 0
                hosts[new_ip] = info
            end
        end
    end

    s = utils.beautify(cjson.encode(hosts))
    utils.write_to_file(utils.hosts_file, s, true)
end


function parse_ifconfig(result)
    local ip = nil
    local mac = nil
    for _, line in pairs(utils.split_line(result)) do
        local words = utils.split_str(line)
        if words[1] == "inet" then
            if words[2] ~= "127.0.0.1" then
                ip = words[2]
            end
        end
        if (words[1] == "ether") and (ip ~= nil) then
            mac = words[2]
            return ip, mac
        end
    end

    return nil
end


function read_macs(network)
    -- read mac adddresses using netdiscover and ifconfig
    -- and updates hosts.txt file

    local cmd = cmd_netdiscover:gsub("NETWORK", network)
    local cmd_result = utils.run_command(cmd)

    local hosts = cjson.decode(utils.read_file(utils.hosts_file))
    if hosts == nil then
        hosts = {}
    else
        for ip, h in pairs(hosts) do
            h["mac_read"] = false
        end
    end

    -- read self mac address
    result = utils.run_command(cmd_ifconfig)
    self_ip, self_mac = parse_ifconfig(result)
    local found = false
    if self_ip ~= nil then
        for ip, h in pairs(hosts) do
            if ip == self_ip then
                h["discovered"] = true
                h["mac_read"] = true
                h["mac"] = self_mac
                found = true
            end
        end
        if not found then
            local info = {}
            info["discovered"] = true
            info["mac_read"] = true
            info["name_resolved"] = false
            info["name"] = ""
            info["mac"] = self_mac
            info["ping_time"] = 0
            hosts[self_ip] = info
        end
    end

    -- read mac addresses of other hosts
    local new_ip
    local found = false
    for _, line in pairs(utils.split_line(cmd_result)) do
        local words = utils.split_str(line)
        if (words[1] ~= "--") and (words[2] ~= nil) then
            new_ip = words[1]
            new_mac = words[2]
            found = false
            for ip, h in pairs(hosts) do
                if ip == new_ip then
                    h["discovered"] = true
                    h["mac_read"] = true
                    h["mac"] = new_mac
                    found = true
                end
            end
            if not found then
                local info = {}
                info["discovered"] = true
                info["mac_read"] = true
                info["name_resolved"] = false
                info["name"] = ""
                info["mac"] = new_mac
                info["ping_time"] = 0
                hosts[new_ip] = info
            end
        end
    end

    s = utils.beautify(cjson.encode(hosts))
    utils.write_to_file(utils.hosts_file, s, true)
end


function ping_hosts()
    local hosts = cjson.decode(utils.read_file(utils.hosts_file))
    if hosts == nil then
        return
    else
        for ip, h in pairs(hosts) do
            h["ping_time"] = 0
        end
    end

    local cmd = ""
    local result = ""
    local time = 0
    for ip, h in pairs(hosts) do
        cmd = cmd_ping .. ip
        result = utils.run_command(cmd)
        time = utils.parse_ping_return(result)
        h["ping_time"] = time
    end

    s = utils.beautify(cjson.encode(hosts))
    utils.write_to_file(utils.hosts_file, s, true)
end


function identify_hosts()
    -- identifies hosts (resolves IPs to names) using avahi-resolve

    local hosts = cjson.decode(utils.read_file(utils.hosts_file))
    if hosts == nil then
        return
    end

    -- resolve only names for newly discovered hosts or those that could be pinged
    local cmd = ""
    local cmd_result = ""
    local new_ip
    local new_name
    for ip, h in pairs(hosts) do
        if (h["ping_time"] > 0) or h["discovered"] then
            cmd = cmd_avahi .. ip
            cmd_result = utils.run_command(cmd)
            new_ip, new_name = utils.parse_avahi_resolve(cmd_result)
            if new_ip == nil then
                h["name_resolved"] = false
            else
                h["name_resolved"] = true
                h["name"] = new_name
            end
        else
            h["name_resolved"] = false
        end
    end

    s = utils.beautify(cjson.encode(hosts))
    utils.write_to_file(utils.hosts_file, s, true)
end


function prepare_name(name)
    if #name > 12 then
        name = name:lower():sub(1, 12)
    end

    return name
end


function read_hosts(network, mac, ping)
    local output = ""
    local cnt = 0

    local time = 0
    local info = ""
    local hname = ""
    local hosts = cjson.decode(utils.read_file(utils.hosts_file))
    if hosts ~= nil then
        for ip, h in utils.spairs(hosts, utils.sort_ips) do
            color_ip = colors.normal
            color_mac = colors.normal
            color_name = colors.normal
            if not h["discovered"] then
                color_ip = colors.warning
            end
            if mac and (not h["mac_read"]) then
                color_mac = colors.warning
            end
            if not h["name_resolved"] then
                color_name = colors.warning
            end

            info = ""
            if ping then
                time = h["ping_time"]
                if time == 0 then
                    info = colors.warning .. "- - -"
                else
                    info = colors.normal .. time .. " ms"
                end
            end

            hname = color_name .. h["name"]
            if mac then
                info = color_mac .. h["mac"]
                hname = color_name .. prepare_name(h["name"])
            end

            output = output .. color_ip .. ip .. cmds.tab(48) .. info ..
                     cmds.rjust .. hname .. "\n"

            cnt = cnt + 1
        end
    end
    local title = colors.text .. network .. cmds.rjust .. colors.title .. "Hosts:  " .. colors.normal .. cnt .. "\n"

    return title .. output
end


function init_hosts(copy)
    -- copy hosts if requested
    if (copy ~= nil) and copy then
        utils.copy_file(utils.hosts_file_save, utils.hosts_file)
    end

    local hosts = cjson.decode(utils.read_file(utils.hosts_file))
    if hosts == nil then
        hosts = {}
    else
        for ip, h in pairs(hosts) do
            h["discovered"] = false
            h["mac_read"] = false
            h["name_resolved"] = false
            h["ping_time"] = 0
        end
    end

    s = utils.beautify(cjson.encode(hosts))
    utils.write_to_file(utils.hosts_file, s, true)
end


local network = arg[1]
local get_mac = false
local get_ping = false
for i = 2, 3 do
    if arg[i] ~= nil then
        if arg[i] == "-m" then
            get_mac = true
        end
        if arg[i] == "-p" then
            get_ping = true
        end
    end
end


local output = ""
local cmd = ""
local cmd_result = ""
if network ~= nil then
    if not utils.file_exists(utils.hosts_file) then
        -- display the saved lists of hosts right away at startup
        init_hosts(true)
    else
        init_hosts()
        discover_hosts(network)
        if get_mac then
            read_macs(network)
        end
        if get_ping then
            ping_hosts()
        end
        identify_hosts()
    end

    output = read_hosts(network, get_mac, get_ping)
end

io.write(output)
