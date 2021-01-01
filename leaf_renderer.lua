--# Tile map -----------------------------------------------#--

leaf.mainground = {}
leaf.background = {}

local block = {}

function block:load()

    local other = {}

    setmetatable(other, self)
    self.__index = self

    return other
end

function block:init(pos, spr)

    self.bpos = pos
    self.sprt = spr
end

function block:draw()

    love.graphics.draw(leaf.tiled, self.sprt, self.bpos.x, self.bpos.y)
end

function leaf.tilemap(main, back, info, itm, obj)

    leaf.mainground = {}
    leaf.background = {}

    -- Clear platforms --
    leaf.del_plat()

    -- Clear items --
    leaf.items = {}

    -- Tiles' definitions --
    local _dict, _thru, _skip = info.dict, info.thru, info.skip

    -- Catchable item --
    local itmc = 0

    -- Create Enemies --
    local spawn
    local enemy = {}
    local temp_x  = 0
    local temp_y  = 0
    local invoke = false

    -- For every line in the map --
    for ty, line in pairs(main) do

        -- Split Line --
        local splitd = line:split(' ')

        -- For every tile in splited line --
        for tx, tile in pairs(splitd) do

            -- Get the tile sprite --
            local this = _dict[tile]

            -- Unknow tile --
            if not this then this = _dict['nil'] end

            -- Set position and draw quad --
            local tpos = leaf.vector(tx - 1, ty, 8)
            local sprt = love.graphics.newQuad(

                this.x,
                this.y,
                8,
                8,
                leaf.tiled:getDimensions()
            )

            -- Load block object --
            table.insert(leaf.mainground, block:load())

--# Configure the block --------------------------------#--

            -- Isn't a solid block --
            if leaf.table_find(_skip, tile) then

                leaf.mainground[#leaf.mainground]:init(tpos, sprt)

            -- Jump _thru platform --
            elseif leaf.table_find(_thru, tile) then

                leaf.mainground[#leaf.mainground]:init(tpos, sprt)
                leaf.add_plat('jthru', tpos, 8, 8)

            -- Solid block --
            else

                leaf.mainground[#leaf.mainground]:init(tpos, sprt)
                leaf.add_plat('solid', tpos, 8, 8)
            end
        end
    end

--# Additional tiles -----------------------------------#--

    -- For every line in the map --
    for ty, line in pairs(back) do

        -- Split blocks --
        local splitd = line:split(' ')

        -- For every tile in splited line --
        for tx, tile in pairs(splitd) do

            -- Get sprite in the _dictionary --
            local this = _dict[tile]

            -- Unknow block --
            if not this then this = _dict['nil'] end

            -- Set position --
            local tpos = leaf.vector((tx - 1), ty, 8)

            -- Spawn point --
            if tile == '@' then

                spawn = leaf.table_copy(tpos):sum(4, 4)

            elseif tile == '#' then

                if not invoke then

                    temp_x = tpos.x
                    temp_y = tpos.y

                    invoke = true

                else

                    enemy[#enemy + 1] = leaf.new_obj(

                        obj.name  ,
                        temp_x + 8,
                        tpos.x - 8,
                        leaf.vector(tpos.x - 8, temp_y),
                        obj.clip
                    )

                    invoke = false
                end

            -- Auto tiling for catchable items --
            elseif itm and tile == itm.tile then

                leaf.add_itm('grass_' .. (itmc), tpos, _dict[itm.tile], itm.wall)
                itmc = itmc + 1

            else

                -- Create quad --
                local sprt = love.graphics.newQuad(

                    this.x,
                    this.y,
                    8,
                    8,
                    leaf.tiled:getDimensions()
                )

                -- Add block --
                table.insert(leaf.background, block:load())
                leaf.background[#leaf.background]:init(tpos, sprt)
            end
        end
    end

    return spawn, enemy
end

local function blink(it)

    if not it.exst then
        -- Blink --
        if it.t > 0 then

            leaf.set_col(99, 199, 77, it.t)

            leaf.rectb(it.x, it.y, 8)
            it.t = it.t - 10

            leaf.set_col()
        -- Del item --
        else leaf.items[it.name] = nil end
    end
end

function leaf.draw_tilemap()

    -- Draw each tile --
    for _, tile in pairs(leaf.mainground) do

        tile:draw()
    end

    for _, tile in pairs(leaf.background) do

        tile:draw()
    end

    -- Draw items --
    for _, itm in pairs(leaf.items) do

        blink(itm)
    end
end

function leaf.add_tile(name, spos, sprt, wall)

    local spr = love.graphics.newQuad(

        sprt.x,
        sprt.y,
        8,
        8,
        leaf.tiled:getDimensions()
    )

    leaf.mainground[name] = block:load(0)
    leaf.mainground[name]:init(spos, spr)

    if wall then

        leaf.add_plat('solid', spos, 8, 8, name)
    end
end

function leaf.del_tile(name)

    if not name then

        leaf.mainground = {}
        leaf.background = {}

        leaf.del_plat()

    else

        leaf.mainground[name] = nil
        leaf.del_plat(name)
    end
end

--# Animator -----------------------------------------------#--

local anim = {}

function anim:load()

    local other = {}

    setmetatable(other, self)
    self.__index = self

    return other
end

function anim:init(frame)

    -- Time cotrol --
    self.afps = 0
    self.timr = 1 / self.afps

    -- Initidal frame --
    self.reload = false
    if not frame then frame = leaf.vector(0, 0) end

    -- Open and store data to animate --
    self.quad = love.graphics.newQuad(frame.x * 8, frame.y * 8, 8, 8, leaf.sheet:getDimensions())
end

function anim:play(dt, anim, speed, loop)

    -- Reset to a new animation --
    if self.canm ~= anim.name then self.reload = true end
    if self.reload then

        self.canm = anim.name
        self.afps = speed
        self.timr = 1 / self.afps

        self.cfrm = anim[0]
        self.nfrm = 0

        -- Set the first frame --
        self.quad:setViewport(self.cfrm * 8, anim.row * 8, 8, 8)

        self.reload = false
    end

    -- Wait if is too slow --
    if dt > 0.035 then return end

    -- Wait for next frame --
    self.timr = self.timr - dt

    -- No time left --
    if self.timr <= 0 then

        -- Reset timer --
        self.timr = 1 / self.afps

        self.nfrm = self.nfrm + 1

        -- For Loop --
        if self.nfrm > anim.count - 1 and loop then self.nfrm = 0 end
        if self.nfrm > anim.count - 1 and not loop then return true end

        -- Next frame --
        self.cfrm = anim[self.nfrm]

        -- Update frame --
        self.quad:setViewport(self.cfrm * 8, anim.row * 8, 8, 8)
    end
end

function anim:loop()

    self.reload = true
end

function anim:draw(pos, side)

    if math.abs(side) > 1 then

        side = 1 * (math.abs(side) / side)
    end

    local xoff = math.min(math.min(8 * side, 8), 0)
    love.graphics.draw(leaf.sheet, self.quad, pos.x - xoff, pos.y, 0, side, 1)
end

function leaf.anim(ifrm)

    local out = anim:load()
    out:init(ifrm)

    return out
end

-- Animation Source --
local function default(name, rw, fx, lx, op)

    fx = fx or 0
    lx = lx or fx

    local src = {}

    -- Frames --
    for a = 0, lx - fx do

        src[a] = fx + a
    end

    -- Optional frames --
    if op then

        for i = lx - fx + 1, lx - fx + op[1] + 1 do

            src[i] = op[2]
        end
    end

    -- Frame count --
    src.count = #src

    -- Animation row --
    src.row = rw or 0

    -- Animation --
    src.name = name

    return src
end

local function stepped(name, rw, fx, mx, lx)

    fx = fx or 1
    mx = mx or fx - 1
    lx = lx or fx + 1

    local src = {[0] = fx, [1] = mx, [2] = lx, [3] = mx}

    -- Frame count --
    src.count = 4

    -- Animation row --
    src.row = rw or 0

    -- Animation --
    src.name = name

    return src
end

function leaf.asrc(name, ...)

    local src

    if name:sub(1, 4) == 'stp-' then

        src = stepped(name, ...)

    elseif name:sub(1, 4) == 'def-' then

        src = default(name, ...)

    else src = default(name, ...) end

    return src
end

--# Text type ----------------------------------------------#--

leaf.texts = {}

local random_offset = leaf.vector()

function leaf.popup(usr, msg)

    local os_n = love.system.getOS()

    if os_n == 'Windows' then

        os.execute('msg ' .. usr .. ' ' .. msg)

    elseif os_n == 'Linux' then

        os.execute('zenity --info --text="' .. msg .. '"')
    end
end

function leaf.txt_conf(font, size, speed)

    font = love.graphics.newFont('resources/' .. font, size)
    love.graphics.setFont(font)

    leaf.lttr_size  = size - size / 4
    leaf.text_speed = speed
end

function leaf.new_txt(tmsg, ypos, effect, trigger, tgrTime)

    -- Avoid overlaping --
    if leaf.txt_exist(tmsg) then return end

    -- Invalid arguments --
    if not type(tmsg) == "string" then

        assert('Attempt to create a text with a not-string message')
    end

    if not type(ypos) == "number" then

        assert('Attempt to draw a text at a non-numeric position (ypos)')
    end

    if not type(effect) == "string" then

        assert('Attempt to create a text with a invalid effect type')
    end


    local t = {

        pos = leaf.vector(0, ypos),

        -- Effects --
        tgr = trigger,
        ttm = tgrTime,
        efc = effect ,

        -- Timer --
        cps   = leaf.text_speed    ,
        speed = leaf.text_speed    ,
        timer = 1 / leaf.text_speed,

        -- Text --
        msg   = tmsg ,
        ctext = ''   ,
        ended = false,
    }

    table.insert(leaf.texts, t)
end

function leaf.type_txt(dt, sound)

    for _, t in pairs(leaf.texts) do

        -- Set random offset --
        random_offset.x = math.random(0, 24)
        random_offset.y = math.random(0, 24)

        -- Dramatic Waiting --
        if t.tgr and leaf.table_find(t.tgr, #t.ctext) then t.cps = t.ttm
        else t.cps = t.speed end

        -- Set the midle position --
        t.pos.x = leaf.s_wdth / 2 - (#t.ctext * leaf.lttr_size) / 2

        -- If isn't too slow --
        if dt > 0.035 then return end

        t.timer = t.timer - dt

        -- Show Text --
        if t.timer <= 0 then

            t.timer = 1 / t.cps
            if t.ctext ~= t.msg then

                t.ctext = t.ctext .. t.msg:sub(#t.ctext + 1, #t.ctext + 1)

            else t.ended = true end

            -- Text sound --
            if sound then leaf.gramo.play(sound) end
        end
    end
end

local function draw_text()

    for _, t in pairs(leaf.texts) do

        -- Draw effects --
        if t.efc == 'noises' then

            leaf.set_col(0, 0, 255, 255/2)
            love.graphics.print(t.ctext, t.pos.x + (random_offset.x / 12), t.pos.y)

            leaf.set_col(255, 0, 0, 255/2)
            love.graphics.print(t.ctext, t.pos.x - (random_offset.y / 12), t.pos.y)

        elseif t.efc == 'glitch' then end

        -- Draw main text --
        leaf.set_col(255, 255, 255, 255)
        love.graphics.print(t.ctext, t.pos.x, t.pos.y)
    end

    leaf.set_col()
end

function leaf.txt_exist(idxr)

    for i, t in pairs(leaf.texts) do

        if t.msg == idxr then

            return true
        end
    end

    return false
end

function leaf.txt_end(idxr)

    for i, t in pairs(leaf.texts) do

        if t.msg == idxr then

            return t.ended
        end
    end
end

function leaf.del_txt(idxr)

    if not idxr then

        leaf.texts = {}
    end

    for i, t in pairs(leaf.texts) do

        if t.msg == idxr then

            leaf.texts[i] = nil
        end
    end
end

function leaf.pop_txt()

    for i, t in pairs(leaf.texts) do

        if t.ended then

            leaf.texts[i] = nil
        end
    end
end

-- Resset color --
local r, g, b, a

-- Graphic functions --
function leaf.set_col(nr, ng, nb, na)

    if not (nr and ng and nb and na) then

        if r and g and b and a then

            love.graphics.setColor(r, g, b, a)
            r, g, b, a = nil, nil, nil, nil
        end

    else

        if not (r and g and b and a) then

            r, g, b, a = love.graphics.getColor()
        end

        love.graphics.setColor(nr/255, ng/255, nb/255, (na or 255)/255)
    end
end

function leaf.rect(x, y, w, h)

    love.graphics.rectangle('line', x, y, w or 1, h or w or 1)
end

function leaf.rectb(x, y, w, h)

    love.graphics.rectangle('fill', x, y, w or 1, h or w or 1)
end

-- Input --
leaf.inputs = {}

function leaf.btn(key)

    return love.keyboard.isDown(key)
end