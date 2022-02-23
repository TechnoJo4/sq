return function(state, list)
    local sq = _G.__sq__
    local sqload = sq.load

    local LIST, QUOTE, FUNCTION, PATTERN, TUPLE, DICT, STRING
        = sq.t.LIST, sq.t.QUOTE, sq.t.FUNCTION, sq.t.PATTERN, sq.t.TUPLE, sq.t.DICT, sq.t.STRING

    local WORD = sq.t.WORD

    -- tostring
    local lstr, sqstr

    lstr = function(l)
        local t = {}

        for i=l.from,l.to do
            t[#t+1] = sqstr(list.get(l, i))
        end

        return table.concat(t, " ")
    end

    sqstr = function(v)
        if type(v) ~= "table" then
            return tostring(v)
        elseif v[0] == STRING then
            return v[1]
        elseif v[0] == LIST then
            return "("..lstr(v[1])..")"
        elseif v[0] == QUOTE then
            return "["..lstr(v[1]).."]"
        elseif v[0] == FUNCTION then
            return "`["..lstr(v[1]).."]"
        else
            -- shouldn't happen
            return tostring(v)
        end
    end

    -- commands
    state.w[":load"] = function(e, s, q)
        local name = list.pop(s)
        assert(type(name) == "table" and name[0] == STRING)
        sqload(e, name[1])
    end

    -- basic words
    state.w["."] = function(e, s, q) -- print top
        print(sqstr(list.pop(s)))
    end

    state.w[";"] = function(e, s, q) -- define
        local name = list.popstart(q)

        -- not a reserved word
        assert(not w[name] or w[name][0] == WORD,
                "redefining '"..name.."' is not allowed.")

        local t = { [0] = WORD }
        repeat
            local a = list.popstart(q)
            t[#t+1] = a
        until list.empty(q)

        if #t > 0 then
            w[name] = t
        else
            w[name] = nil
        end
    end

    -- core operations

    state.w["_s"] = function(e, s, q) -- add stack to stack
        list.append(s, { [0] = QUOTE, s })
    end

    state.w["_q"] = function(e, s, q) -- add queue to stack
        list.append(s, { [0] = QUOTE, q })
    end

    state.w["<-"] = function(e, s, q) -- stack
        local l = list.pop(s)
        assert(list.is(l))
        e.s = l
    end

    state.w["->"] = function(e, s, q) -- queue
        local l = list.pop(s)
        assert(list.is(l))
        e.q = l
    end

    state.w["<="] = function(e, s, q) -- uncache
        list.append(s, list.pop(q))
    end

    state.w["=>"] = function(e, s, q) -- cache
        list.append(q, list.pop(s))
    end

    state.w["/"] = function(e, s, q) -- use
        local v = list.pop(s)
        if list.is(v) then
            for i=v.to,v.from,-1 do
                list.prepend(q, list.get(v, i))
            end
        else
            list.prepend(q, v)
        end
    end

    state.w["\\"] = function(e, s, q) -- mention
        list.append(s, list.popstart(q))
    end


    -- binary operators
    -- TODO: projection if not enough args?

    state.w["+"] = function(e, s, q)
        local a, b = list.pop(s), list.pop(s)
        list.append(s, a + b)
    end

end
