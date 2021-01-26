--# Tile map -----------------------------------------------#--

leaf.mainground = {}
leaf.background = {}

local block = {}

function block:new(pos, spr)

    local other = {}

    setmetatable(other, self)
    self.__index = self

    other.bpos = pos
    other.sprt = spr

    return other
end

function block:draw()

    love.graphics.draw(
        leaf.tiled,
        self.sprt ,
        self.bpos.x,
        self.bpos.y
    )
end

function leaf.tilemap(back, main, info, itm, obj)
    -- info.skipt: unsolid tiles  --
    -- info.jthru: jumpthru tiles --
    -- info.index: metatiles data --
    leaf.background = {}
    leaf.mainground = {}

    -- clear platforms --
    leaf.del_plat()

    -- item count --
    local itmc = 0
    -- metatiles --
    local spawn
    local _temp
    local enemy = {}

    for _, t in ipairs(back) do

        local sprt = love.graphics.newQuad(

            t.s.x, t.s.y, 8, 8, leaf.tiled:getDimensions()
        )
        local tile = block:new(leaf.vector(t.p.x, t.p.y, 8), sprt)

        if info then
            -- Avoid nil indexing --
            if not (info.skipt or info.jthru) then

                leaf.add_plat('solid', t.p * 8, 8, 8)
                goto continue
            end

            if     info.skipt[t.c] then goto continue
            elseif info.jthru[t.c] then

                leaf.add_plat('jthru', t.p * 8, 8, 8)

            else leaf.add_plat('solid', t.p * 8, 8, 8) end
        end

        ::continue::
        table.insert(leaf.background, tile)
    end

    if main then

        for p, t in pairs(main) do

            local sprt = love.graphics.newQuad(

                t.s.x, t.s.y, 8, 8, leaf.tiled:getDimensions()
            )
            local tile = block:new(leaf.vector(t.p.x, t.p.y, 8), sprt)

            if info and info.index then

                if itm and itm.tile[t.c] then

                    leaf.add_itm(itm.name[t.c] .. (itmc), t.p * 8, t.s, itm.wall[t.c])

                    itmc = itmc + 1
                    goto continue
                end

                if info.index.spawn == t.c then

                    spawn = t.p
                    goto continue
                end

                if info.index.enemy == t.c then

                    if not _temp then

                        _temp = t.p
                    else
                        enemy[#enemy + 1] = leaf.create(

                            obj.name,
                            _temp.x * 8 + 8,
                              t.p.x * 8 - 8,
                            leaf.vector(t.p.x - 1, _temp.y, 8),
                            obj.clip
                        )
                        _temp = nil
                    end

                else table.insert(leaf.mainground, tile) end

            else table.insert(leaf.mainground, tile) end
            ::continue::
        end
    end
    return spawn, enemy
end

local function blink(it)

    if not it.exst then
        -- blink --
        if it.t > 0 then

            leaf.color(99, 199, 77, it.t)

            leaf.rectb(it.x, it.y, 8)
            it.t = it.t - 10

            leaf.color()
        -- Del item --
        else
            leaf.items[it.name] = nil
        end
    end
end

function leaf.draw_tilemap()
    -- Draw each tile --
    for _, tile in pairs(leaf.background) do

        tile:draw()
    end

    for _, tile in pairs(leaf.mainground) do

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

    leaf.mainground[name] = block:new(spos, spr)

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

local random_offset = leaf.vector(0, 0)

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
    if not effect then effect = "" end

    -- Invalid arguments --
    assert(type(tmsg) == "string", 'Attempt to create a text with a not-string message')
    assert(type(ypos) == "number", 'Attempt to draw a text at a non-numeric position (ypos)')
    assert(type(effect) == "string", 'Attempt to create a text with a invalid effect type')

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

function leaf.type_txt(dt, sound, channel)

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
                -- text sound --
                if sound then leaf.gramo.play(sound, channel or 7) end

            else t.ended = true end
        end
    end
end

function leaf.draw_text()

    for _, t in pairs(leaf.texts) do
        -- Draw effects --
        if t.efc == 'noises' then

            leaf.color(0, 0, 255, 127.5)
            love.graphics.print(t.ctext, t.pos.x + (random_offset.x / 12), t.pos.y)

            leaf.color(255, 0, 0, 127.5)
            love.graphics.print(t.ctext, t.pos.x - (random_offset.y / 12), t.pos.y)

        elseif t.efc == 'glitch' then end

        -- Draw main text --
        leaf.color(255, 255, 255)
        love.graphics.print(t.ctext, t.pos.x, t.pos.y)
    end

    leaf.color()
end

function leaf.txt_exist(idxr)

    for i, t in pairs(leaf.texts) do

        if t.msg == idxr then return true end
    end

    return false
end

function leaf.txt_end(idxr)

    for i, t in pairs(leaf.texts) do

        if t.msg == idxr then return t.ended end
    end
end

function leaf.del_txt(idxr)

    if not idxr then leaf.texts = {} end

    for i, t in pairs(leaf.texts) do

        if t.msg == idxr then leaf.texts[i] = nil end
    end
end

function leaf.pop_txt()

    for i, t in pairs(leaf.texts) do

        if t.ended then leaf.texts[i] = nil end
    end

    collectgarbage('collect')
end

-- Resset color --
local r, g, b, a

-- Graphic functions --
function leaf.color(nr, ng, nb, na)
    -- default value --
    na = na or 255

    if not (nr and ng and nb and na) then

        if r and g and b and a then

            love.graphics.setColor(r, g, b, a)
            return r, g, b, a
        end
    else
        if not (r and g and b and a) then

            r, g, b, a = love.graphics.getColor()
        end

        love.graphics.setColor(nr / 255, ng / 255, nb / 255, na / 255)
    end
end

function leaf.bg_color(nr, ng, nb, na)

    love.graphics.setBackgroundColor(nr / 255, ng / 255, nb / 255, (na or 255) / 255)
end

function leaf.rect(x, y, w, h)

    love.graphics.rectangle('line', x, y, w or 1, h or w or 1)
end

function leaf.rectb(x, y, w, h)

    love.graphics.rectangle('fill', x, y, w or 1, h or w or 1)
end
