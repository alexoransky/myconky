--
-- Alex Oransky, 2019
-- https://github.com/alexoransky/myconky
--

-- This module provides interface for storing and rethrieving save files
-- to HDD from RAM disk and back.

files = {}

require "utils"

files.temp_path = "/mnt/ramdisk/"
files.perm_path = "/home/alex/.config/conky/"

-- save files
files.hosts = "conky_hosts.txt"
files.printer = "conky_printer.txt"

function files.restore_file(fname)
    local hdd_path = files.perm_path .. fname
    local tmp_path = files.temp_path .. fname

    if (not utils.file_exists(tmp_path)) and (utils.file_exists(hdd_path)) then
        utils.copy_file(hdd_path, tmp_path)
        return true
    end

    return false
end

function files.save_file(fname)
    local hdd_path = files.perm_path .. fname
    local tmp_path = files.temp_path .. fname

    utils.copy_file(tmp_path, hdd_path)
end

return files
