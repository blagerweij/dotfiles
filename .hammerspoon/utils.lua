--
-- Various util functions
--

local This = {}

-- Sugar for binding functions
function This:bind(reference, functionName)
    return function()
        reference[functionName](reference)
    end
end

-- Sugar for adding to tables
function This:addToTable(target, inputTable)
    for _, value in pairs(inputTable) do
        table.insert(target, value)
    end
end

-- Sugar for splitting a string into a table
function This:split(s, delimiter)
    local result = {}
    for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
        if (match ~= "") then
            table.insert(result, match)
        end
    end
    return result
end

-- Sugar for reversing a table
function This:reverse(table)
    local n = #table
    local i = 1
    while i < n do
        table[i], table[n] = table[n], table[i]
        i = i + 1
        n = n - 1
    end
end

local function urlencode(s) return s and (s:gsub("%W", function (c) return string.format("%%%02x", c:byte()); end)); end
local function urldecode(s) return s and (s:gsub("%%(%x%x)", function (c) return string.char(tonumber(c,16)); end)); end

local function _formencodepart(s)
    return s and (s:gsub("%W", function (c)
        if c ~= " " then
            return string.format("%%%02x", c:byte())
        else
            return "+"
        end
    end))
end

function This:formencode(form)
    local result = {}
    for name, value in pairs(form) do
        table.insert(result, _formencodepart(name).."=".._formencodepart(value))
    end
    return table.concat(result, "&")
end

function This:formdecode(s)
    local r = {}
    for k, v in s:gmatch("([^=&]*)=([^&]*)") do
        k, v = k:gsub("%+", "%%20"), v:gsub("%+", "%%20")
        k, v = urldecode(k), urldecode(v)
        r[k] = v
    end
    return r
end

local _CHARSET = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
math.randomseed(hs.timer.absoluteTime())

function This:randomString(length)
    local ret = {}
    local r
    for i = 1, length do
        r = math.random(1, #_CHARSET)
        table.insert(ret, _CHARSET:sub(r, r))
    end
    return table.concat(ret)
end

return This
