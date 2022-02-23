-- gets the directory containing this file, so that we can load other files in
-- the directory. this is useful because the package may be installed anywhere,
-- so `require` is not reliable. also used to read the prelude.
local root = debug.getinfo(1, "S").source:match("@?(.+[/\\]).-$")
assert(root, "could not get module root")

local list = loadfile(root .. "list.lua")()
local parse = loadfile(root .. "parse.lua")()

-- value types
local LIST, QUOTE, FUNCTION, PATTERN, TUPLE, DICT, STRING
    = "list", "quote", "function", "pattern", "tuple", "dict", "string"

-- not a value type but uhhhhhh
local WORD = "word"

-- do one step of evaluation
local function step(state)
    local w = list.popstart(state.q)
    if state.w[w] then
        w = state.w[w]
        local t = type(w)

        if t == "function" then
            w(state, state.s, state.q)
        elseif t == "table" and t[0] == WORD then
            for i=#t,1,-1 do
                list.prepend(state.q, t[i])
            end
        else
            -- ?
            error("illegal word definition?")
        end

        return
    elseif type(w) == "table" then
        if w[0] == FUNCTION then
            for i=#t,1,-1 do
                list.prepend(state.q, t[i])
            end

            return
        end
    end
    list.append(state.s, w)
end

-- evaluate until nothing left in the queue
local function eval(state)
    while list.len(state.q) > 0 do
        step(state)
    end
end

-- preprocesses the parse tree into a value list for the execution queue
local function preprocess(p)
    for k,v in ipairs(p) do
        if type(v) == "table" then
            if v[0] == LIST then
                p[k] = preprocess(v[1])
            else
                v[1] = preprocess(v[1])
            end
        end
    end
    return list.fromtable(p)
end

-- load a library into the state
local function sqload(state, file)
    if file:sub(1,1) == ":" then
        file = root.."lib/"..file:sub(2)
    end

    local f = io.open(file, "rb")
    if not f then
        error("file '".. file .."' does not exist\n")
    end

    local c = f:read("*a")
    f:close()

    if file:sub(-4) == ".lua" then
        local f, err = load(c, "@"..file)
        if err then
            error("file '".. file .."' failed to compile")
        end

        f()(state, list)
    else
        list.prepend(state.q, { [0] = FUNCTION, preprocess(parse(c)) })
    end
end

-- create a new evalutation state
local function newstate(std)
    local state = {
        w = {}, -- words
        s = list.new(), -- stack
        q = list.new(), -- queue
    }

    -- load standard library
    std = std or { ":core.lua", ":sq.sq" }
    for _,v in ipairs(std) do
        sqload(state, v)
    end

    return state
end

-- parse, preprocess, create new state, eval
local function runstr(str, name)
    local p = parse(str)
    p = preprocess(p)

    local state = newstate()
    state.q = p

    eval(state)
end



local sq = {
    eval = eval,
    step = step,
    load = sqload,
    newstate = newstate,
    preprocess = preprocess,
    runstr = runstr,

    t = {
        LIST = LIST,
        QUOTE = QUOTE,
        FUNCTION = FUNCTION,
        PATTERN = PATTERN,
        TUPLE = TUPLE,
        DICT = DICT,
        STRING = STRING,

        WORD = WORD
    }
}

_G.__sq__ = sq
return sq
