local s_match = string.match

-- value types which can be constructed from the syntax
local LIST, QUOTE, FUNCTION, PATTERN, STRING = "list", "quote", "function", "pattern", "string"

-- TODO: better errors

-- stream: string with position
-- helper methods
local _stream = {
    go = function(s, pos)
        s.pos = pos
        return s.str:sub(pos, pos)
    end,
    match = function(s, pat)
        return s_match(s.str, pat, s.pos)
    end
}

-- constructor
local function stream(str)
    local self = {
        str = str, pos = 1
    }

    if type(str) ~= "string" then
        print("error: cannot parse")
        os.exit()
    end

    for k,v in pairs(_stream) do
        self[k] = v
    end

    return self
end

local function token(s)
    -- skip whitespace & comments
    local WHITESPACE = "[ \n\r\t]*()"
    local c = s:go(s:match("^"..WHITESPACE))
    while s:match("^//") do
        c = s:go(s:match("^.-\n" .. WHITESPACE))
    end

    -- punctuation
    if c == "`" or c == ";" or c == "[" or c == "]" or c == "(" or c == ")" or c == "{" or c == "}" then
        s.pos = s.pos + 1
        return { c }
    end

    -- strings
    if c == "\"" then
        -- todo: strings
        return { [0] = STRING }
    end

    -- EOF
    if c == "" then return end

    local word, pos = s:match("^([^ \n\r\t]+)()")
    s:go(pos)

    -- try to parse as number
    local num = tonumber(s:match("^(%-?[0-9]*%.?[0-9]*)"))
    if num then return num end

    return word
end

local function parse(s, tok)
    tok = token(s)

    if type(tok) ~= "table" or tok[0] then
        return tok
    end

    local c = tok[1]
    -- TODO: everything

    -- return { [0] = LIST, l }
end

return function(str)
    local s = stream(str)
    local t = {}

    repeat
        local p = { parse(s) }
        for _,v in ipairs(p) do
            t[#t+1] = v
        end
    until #p == 0

    return t
end
