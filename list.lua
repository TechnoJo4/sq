-- double-ended stack?

local m = {}

function m.new()
    return {
        [0] = {},
        from = 0,
        to = -1
    }
end

function m.empty(l)
    return l.to < l.from
end

function m.is(l)
    return l.to and l.from and type(l[0]) == "table"
end

function m.len(l)
    return l.to - l.from + 1
end

function m.get(l, p)
    if p < 0 then
        return l[0][-p]
    end
    return l[p+1]
end

function m.set(l, p, v)
    if p < 0 then
        l[0][-p] = v
    end
    l[p+1] = v
end

function m.first(l) -- index 0
    m.get(l, l.from)
end

function m.last(l) -- index -1
    m.get(l, l.to)
end

function m.index(l, p)
    if p < 0 then
        return m.get(l, l.to + p + 1)
    end
    return m.get(l, l.from + p)
end

function m.prepend(l, v)
    l.from = l.from - 1
    m.set(l, l.from, v)
end

function m.append(l, v)
    l.to = l.to + 1
    m.set(l, l.to, v)
end

function m.popstart(l)
    local v

    if l.from < 0 then
        v = l[0][-l.from]
        l[0][-l.from] = nil
    end
    v = l[l.from+1]
    l[l.from+1] = nil

    l.from = l.from + 1
    return v
end

function m.pop(l)
    local v

    if l.to < 0 then
        v = l[0][-l.to]
        l[0][-l.to] = nil
    end
    v = l[l.to+1]
    l[l.to+1] = nil

    l.to = l.to - 1
    return v
end

function m.fromtable(t)
    local l = m.new()
    for i,v in ipairs(t) do
        l[i] = v
    end
    l.to = #l - 1
    return l
end

return m
