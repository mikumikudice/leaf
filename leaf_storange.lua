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

            meta = 'return {\n'

            for i, v in pairs(data) do

                if type(i) == "number" then

                    i = '[' .. (i) .. ']'
                end

                meta = meta .. '\n\t' .. i .. '=' .. v .. ','
            end

            meta = meta .. '\n}'

        elseif type(data) == "string"
            or type(data) == "number" then

            meta = 'return ' .. (data)

        else

            success, message = false, 'Invalid serializable data'
        end

        -- Write it on file --
        if meta then

            success, message = love.filesystem.write(file .. '.lua', meta)
        end
    end

    -- Error --
    assert(success, message)
end

function leaf.load_data(file, method)

    -- Safe method --
    if method == 'safe' then

        local splt, line
        local out = {}

        -- Open and read all lines --
        if love.filesystem.getInfo(file) then

            line = love.filesystem.read(file)

        else return end

        -- Break text on enters --
        line = line:split('\n')

        -- Remove message --
        line[1] = nil

        -- Read every line --
        for idx, itm in pairs(line) do

            -- Get value name and value --
            splt = itm:split(':')

            -- Convert to correct data type --
            if tonumber(splt[1]) then splt[1] = tonumber(splt[1]) end
            if tonumber(splt[2]) then splt[2] = tonumber(splt[2])
            elseif tobool(splt[2]) then splt[2] = tobool(splt[2]) end

            -- Store loaded data --
            out[splt[1]] = splt[2]
        end

        return out
    end

    -- Default storange --
    if not method then

        if love.filesystem.getInfo(file .. '.lua') then

            return love.filesystem.load(file .. '.lua')()
        end
    end
end