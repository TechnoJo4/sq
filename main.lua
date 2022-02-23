local args = {...}
if #args == 0 then
    args = { "-f", "repl.sq" }
end

local first = args[1]

if #args == 2 and first == "-e" or first == "-f" then
    local program, name = args[2], args[2]
    if first == "-f" then
        local f = io.open(program, "rb")
        if not f then
            io.stderr:write("error: '", program, "' does not exist\n")
            os.exit(1)
        end
        program = f:read("*a")
        f:close()
    end

    local eval = require("eval")
    eval.runstr(program, name)
else
    io.stderr:write("usage: -e 'program' | -f file\n")
    os.exit()
end
