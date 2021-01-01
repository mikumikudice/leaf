function leaf.debug(tag, ...)

    local arg = {...}

    if type(tag) == 'table' then

        -- Check Leaf Object Type --
        if tag.lot then

            tag = tag:str()
        else

            local tmp = ''
            for i, v in pairs(tag) do

                if tmp ~= '' then

                    if type(i) ~= 'number' then

                        tmp = tmp .. ', ' .. (i) .. ': '

                    else tmp = tmp .. ', ' end
                else

                    if type(i) ~= 'number' then

                        tmp = (i) .. ': '
                    end
                end

                tmp = tmp .. tostring(v)
            end

            tag = tmp
        end
    end

    -- Make all arguments strings --
    for i, a in pairs(arg) do

        if type(tag) == 'table' then

            if a.lot then

                arg[i] = a:str()
            end

        else arg[i] = tostring(a) end
    end

    -- Concat arguments --
    arg = table.concat(arg, ", ")

    local out = '[' .. tostring(tag) .. ']'

    if arg ~= '' then out = out ..  '[' .. arg .. ']' end
    print(out)
end

function leaf.table_first(lst)

    for i, v in pairs(lst) do

        return i, v
    end
end

function leaf.table_last(lst)

    local idx, val

    for i, v in pairs(lst) do

        idx, val = i, v
    end

    return idx, val
end

function leaf.table_find(lst, val)

    for idx, itm in pairs(lst) do

        if itm == val then return idx end
    end
end

function leaf.table_eq(lst, otr)

    for i in pairs(lst) do

        if lst[i] ~= otr[i] then return false end
    end

    return true
end

function leaf.table_copy(lst)

    local other = {}

    for idx, val in pairs(lst) do

        other[idx] = val
    end

    return other
end

function string.split(self, pat)

    -- Table to store substrings --
    local subs = {}

    -- For every word --
    while true do

        -- Get index of substring (div) --
        local findx, lindx = self:find(pat)

        -- Store last substring --
        if not findx then

            subs[#subs + 1] = self
            break
        end

        -- Store the substring before (div) --
        subs[#subs + 1], self = self:sub(1, findx - 1), self:sub(lindx + 1)
    end

    return subs
end

function string.startswith(self, sub)

    return self:sub(1, #sub) == sub
end

function string.endswith(self, sub)

    return self:sub(-#sub) == sub
end

function tobool(value)

    if type(value) == 'string' then
    if value:lower() == 'true' then return true
    end

    elseif type(value) == 'number' then return value ~= 0
    else return value ~= nil end
end