-- Storange --
function leaf.save_data(file, data, method, msg)

    local meta, success, message

    -- Safe method --
    if method == 'safe' then

        -- Create file or read it --
        local line = (msg .. '\n') or 'gamedata\n'

        -- Write every value in pairs --
        for idx, itm in pairs(data) do

            line = line .. tostring(idx) .. ':' .. tostring(itm) .. '\n'
        end

        -- Remove the last enter (\n) --
        line = line:sub(1, -2)

        -- Write it on file --
        success, message = love.filesystem.write(file, line)
    end

    -- Default storange --
    if not method then

        if type(data) == 'boolean' then

            data = tostring(data)
        end

        if type(data) == "table" then

            meta = 'return {'

            for i, v in pairs(data) do

                if type(i) == "number" then

                    i = '[' .. (i) .. ']'
                end

                if type(v) == "string" then v = '"' .. v .. '"' end
                meta = meta .. '\n\t' .. i .. '=' .. tostring(v) .. ','
            end

            meta = meta .. '\n}'

        elseif type(data) == "string" then meta = 'return "' .. data .. '"'
        elseif type(data) == "number" then meta = 'return ' .. (data)
        else
            success, message = false, 'Invalid serializable data'
        end
        -- write it on file --
        if meta then
            success, message = love.filesystem.write(file .. '.lua', meta)
        end
    end
    -- error --
    assert(success, message)
end

function leaf.load_data(file, method)
    -- safe method --
    if method == 'safe' then

        local splt, line
        local out = {}
        -- open and read all lines --
        if love.filesystem.getInfo(file) then

            line = love.filesystem.read(file)

        else return end

        -- break text on enters --
        line = line:split('\n')

        -- remove message --
        line[1] = nil
        -- empty file --
        if #line == 0 then return end

        -- read every line --
        for idx, itm in pairs(line) do
            -- get value name and value --
            splt = itm:split(':')

            -- convert to correct data type --
            if tonumber(splt[1]) then splt[1] = tonumber(splt[1]) end
            if tonumber(splt[2]) then splt[2] = tonumber(splt[2])
            elseif tobool(splt[2]) then splt[2] = tobool(splt[2]) end
            -- store loaded data --
            out[splt[1]] = splt[2]
        end

        return out
    end
    -- default storange --
    if not method then

        if love.filesystem.getInfo(file .. '.lua') then

            return love.filesystem.load(file .. '.lua')()
        end
    end
end
