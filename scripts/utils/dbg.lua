--
-- Alex Oransky, 2018
-- https://github.com/alexoransky/myconky
--

dbg = {}

function dbg.printlist(lst)
    for i = 1, #lst do
        io.write(lst[i] .. "\n")
    end
end

return dbg
