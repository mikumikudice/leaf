--# tilemap ------------------------------------------------#--

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
    local pos
    if leaf.drawmode == "default" then
        pos = self.bpos
    elseif leaf.drawmode == "pixper" then
        pos = leaf.vector(
            math.floor(self.bpos.x),
            math.floor(self.bpos.y)
        )
    end
    love.graphics.draw(
        leaf.tiled,
        self.sprt ,
        pos.x,
        pos.y
    )
end

--- sets the tilemap in the foreground (solid) and in the background\
--- note that the tilemap is ereased before set again
--- @param back table background tiles
--- @param main table mainground tiles
--- @param info table contains the tilemap metadata
--- @param itm  table contains the catchable items of the map
--- @param obj  table contains the data of the spawnable enemies in the map
--- @return vector spawn the spawn position found in the map
--- @return table  enemies all the enemies instantiated by the map
function leaf.tilemap(back, main, info, itm, obj)
    -- info.skipt: nonsolid tiles --
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

    assert(back, 'missing tilemap data (back is nil)')

    -- for layer in background --
    for _, l in ipairs(back) do
        -- for tile in layer --
        for _, t in ipairs(l) do

            local sprt = love.graphics.newQuad(

                t.s.x, t.s.y, 8, 8, leaf.tiled:getDimensions()
            )
            local tile = block:new(leaf.vector(t.p.x, t.p.y, 8), sprt)

            if info then
                -- avoid nil indexing --
                if not (info.skipt or info.jthru) then

                    leaf.add_plat('solid', leaf.newsqr(t.p.x * 8, t.p.y * 8, 8))
                    goto continue
                end

                if     info.skipt[t.c] then goto continue
                elseif info.jthru[t.c] then

                    leaf.add_plat('jthru', leaf.newsqr(t.p.x * 8, t.p.y * 8, 8))

                else leaf.add_plat('solid', leaf.newsqr(t.p.x * 8, t.p.y * 8, 8)) end
            end

            ::continue::
            leaf.background[#leaf.background + 1] = tile
        end
    end

    if main then
        for _, t in pairs(main) do

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

                if info.index.enemy[t.c] then

                    if not _temp then

                        _temp = t.p
                    else
                        enemy[#enemy + 1] = leaf.create(

                            obj[t.c].name,
                            _temp.x * 8 + 8,
                                t.p.x * 8 - 8,
                            leaf.vector(t.p.x - 1, _temp.y, 8),
                            obj[t.c].clip
                        )
                        _temp = nil
                    end

                else leaf.mainground[#leaf.mainground + 1] = tile end

            else leaf.mainground[#leaf.mainground + 1] = tile end
            ::continue::
        end
    end
    return spawn, enemy
end

--- decodes a binary file outputed by the Ethereal tilemap editor
--- @param file string file path
--- @return table back the 
--- @return table main
function leaf.decoder(file)
    local info = love.filesystem.getInfo(file)
    local cntt = love.filesystem.read(file)

    local backdata
    local maindata = cntt:sub(info.size - 288, info.size):split('ç')

    local _back = {}
    local _main = {}

    for chunk = 0, info.size - 376, 288 do
        -- init table --
        _back[chunk / 288 + 1] = {}

        backdata =
        cntt:sub(chunk, chunk + 288):split('ç')

        for y = 0, #backdata - 1 do
            --- internal class\
            --- type that holds the (final) tiles data, i.e. the tiles used by leaf.tilemap
            --- @class tileobj
            --- @field p vector
            --- @field s vector
            --- @field c number

            local line = backdata[y + 1]
            for x = 0, #line - 1 do

                local rt = line:sub(x + 1, x + 1):byte()
                local sx = rt % 16
                local sy = (rt - sx) / 16

                --- @type tileobj
                local tile = {
                    p = leaf.vector(x * 8 + 4, y * 8 + 4, 0.125),
                    s = leaf.vector(sx, sy, 8),
                    c = rt
                }
                table.insert(_back[chunk / 288 + 1], tile)
            end
        end
    end

    for y = 0, #maindata - 1 do

        local line = maindata[y + 1]
        for x = 0, #line - 1 do

            local rt = line:sub(x + 1, x + 1):byte()
            local sx = rt % 16
            local sy = (rt - sx) / 16

            --- @type tileobj
            local tile = {
                p = leaf.vector(x * 8 + 4, y * 8 + 4, 0.125),
                s = leaf.vector(sx, sy, 8),
                c = rt
            }
            table.insert(_main, tile)
        end
    end
    return _back, _main
end

local function blink(it)

    if not it.exst then
        -- blink --
        if it.t > 0 then

            leaf.color(99, 199, 77, it.t)

            leaf.rectb(it.x, it.y, 8)
            it.t = it.t - 10

            leaf.color()
        -- del item --
        else leaf.items[it.name] = nil end
    end
end

function leaf.draw_tilemap()
    -- draw each tile --
    for _, tile in pairs(leaf.background) do

        tile:draw()
    end

    for _, tile in pairs(leaf.mainground) do

        tile:draw()
    end
    -- draw items --
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

        leaf.add_plat('solid', leaf.newsqr(spos.x, spos.y, 8), name)
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

--# animator -----------------------------------------------#--

--- animator class\
--- you should not access the animator fields. instead,
--- it supposed to be used only by the other classes, internally
--- @class animator
--- @field afps number the current count of frames per second of the animation
--- @field canm string the name of the current animation
--- @field cfrm number current frame of the animation
--- @field nfrm number the index of the current frame in the animation src table
--- @field reload boolean sets the animator to restart the animation (set things to firt frame)
--- @field timr number the internal timer of the animation
local anim = {}

--- animation src
--- @class asrc
--- @field count number the count of frames of the animation
--- @field row number the sprite sheet table row where the animation is
--- @field name string the name of the animation

function anim:load()

    local other = {}

    setmetatable(other, self)
    self.__index = self

    return other
end

function anim:init(frame)
    -- time cotrol --
    self.afps = 0
    self.timr = 1 / self.afps

    -- initidal frame --
    self.reload = false
    if not frame then frame = leaf.vector(0, 0) end
    -- open and store data to animate --
    self.quad = love.graphics.newQuad(frame.x * 8, frame.y * 8, 8, 8, leaf.sheet:getDimensions())
end

function anim:play(dt, anm, speed, loop)
    -- reset to a new animation --
    if self.canm ~= anm.name then self.reload = true end
    if self.reload then

        self.canm = anm.name
        self.afps = speed
        self.timr = 1 / self.afps

        self.cfrm = anm[0]
        self.nfrm = 0

        -- Set the first frame --
        self.quad:setViewport(self.cfrm * 8, anm.row * 8, 8, 8)

        self.reload = false
    end

    -- wait if is too slow --
    if dt > 0.035 then return end
    -- wait for next frame --
    self.timr = self.timr - dt

    -- no time left --
    if self.timr <= 0 then
        -- reset timer --
        self.timr = 1 / self.afps

        self.nfrm = self.nfrm + 1

        -- for Loop --
        if self.nfrm > anm.count - 1 and loop then self.nfrm = 0 end
        if self.nfrm > anm.count - 1 and not loop then return true end

        -- next frame --
        self.cfrm = anm[self.nfrm]
        -- update frame --
        self.quad:setViewport(self.cfrm * 8, anm.row * 8, 8, 8)
    end
end

function anim:loop()

    self.reload = true
end

function anim:draw(pos, side)
    -- check for nil --
    assert(pos and side, 'the given values are nil')

    if math.abs(side) > 1 then

        side = math.abs(side) / side
    end

    local xoff = math.min(math.min(8 * side, 8), 0)

    if leaf.drawmode == "pixper" then
        pos = leaf.vector(
            math.floor(pos.x),
            math.floor(pos.y)
        )
    end

    love.graphics.draw(leaf.sheet, self.quad,
    math.floor(pos.x - xoff), math.floor(pos.y), 0, side, 1)
end

function leaf.anim(ifrm)

    local out = anim:load()
    out:init(ifrm)

    return out
end

-- animation source --
local function default(name, rw, fx, lx, op)

    fx = fx or 0
    lx = lx or fx

    local src = {}
    -- frames --
    for a = 0, lx - fx do

        src[a] = fx + a
    end
    -- optional frames --
    if op then

        for i = lx - fx + 1, lx - fx + op[1] + 1 do

            src[i] = op[2]
        end
    end

    -- frame count --
    src.count = #src
    -- animation row --
    src.row = rw or 0

    -- animation --
    src.name = name

    return src
end

local function stepped(name, rw, fx, mx, lx)

    fx = fx or 1
    mx = mx or fx - 1
    lx = lx or fx + 1

    local src = {[0] = fx, [1] = mx, [2] = lx, [3] = mx}

    -- frame count --
    src.count = 4
    -- animation row --
    src.row = rw or 0

    -- animation --
    src.name = name

    return src
end

--- returns a new animation source (sample of sprites for the animator class).
--- the aditional arguments can be int pairs (table) or ints themselves.
--- when in pairs the [1] sprite will be appended [2] times at the end of the animation.
--- when not, simply will be appended at the end of the animation.
--- @param name string the name of the animation
--- @param row  number the row of the sprite table where the animation is
--- @param frst number the position of the first sprite of the animation
--- @param last number the position of the last sprite of the animation
--- @return asrc src
function leaf.asrc(name, row, frst, last, ...)

    local src
    if name:sub(1, 4) == 'stp-' then

        src = stepped(name, row, frst, last, ...)

    elseif name:sub(1, 4) == 'def-' then

        src = default(name, row, frst, last, ...)

    else src = default(name, row, frst, last, ...) end

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

    leaf.font = love.graphics.newFont('resources/' .. font, size)
    love.graphics.setFont(leaf.font)

    leaf.font_size  = size
    leaf.text_speed = speed
end

function leaf.new_txt(tmsg, ypos, effect, trigger, tgrTime)

    -- avoid overlaping --
    if leaf.txt_exist(tmsg) then return end
    if not effect then effect = "" end

    -- Invalid arguments --
    assert(type(tmsg) == "string", 'Attempt to create a text with a not-string message')
    assert(type(ypos) == "number", 'Attempt to draw a text at a non-numeric position (ypos)')
    assert(type(effect) == "string", 'Attempt to create a text with a invalid effect type')

    local t = {
        pos = leaf.vector(0, ypos),
        -- effects --
        tgr = trigger,
        ttm = tgrTime,
        efx = effect ,
        -- timer --
        cps   = leaf.text_speed    ,
        speed = leaf.text_speed    ,
        timer = 1 / leaf.text_speed,
        -- text --
        msg   = tmsg ,
        ctext = ''   ,
        ended = false,
    }

    table.insert(leaf.texts, t)
end

function leaf.type_txt(dt, sound, channel)

    for _, t in pairs(leaf.texts) do
        -- set random offset --
        random_offset.x = math.random(1, 64)
        random_offset.y = math.random(1, 64)

        -- dramatic waiting --
        if t.tgr and leaf.table_find(t.tgr, #t.ctext) then t.cps = t.ttm
        else t.cps = t.speed end

        -- if isn't too slow --
        if dt > 0.035 then return end

        t.timer = t.timer - dt

        -- show text --
        if t.timer <= 0 then

            t.timer = 1 / t.cps
            if t.ctext ~= t.msg then

                t.ctext = t.ctext .. t.msg:sub(#t.ctext + 1, #t.ctext + 1)
                -- text sound --
                if sound then leaf.gramo.play(sound, channel or 7) end

            else t.ended = true end
        end

        -- set the midle position --
        t.pos.x = leaf.s_wdth / 2 - leaf.font:getWidth(t.ctext) / 2
    end
end

function leaf.draw_text()

    for _, t in pairs(leaf.texts) do
        local pos
        if leaf.drawmode == "default" then
            pos = t.pos
        elseif leaf.drawmode == "pixper" then
            pos = leaf.vector(
                math.floor(t.pos.x),
                math.floor(t.pos.y)
            )
        end
        -- draw effects --
        if t.efx == 'noises' then

            leaf.color(0, 0, 255, 127.5)
            love.graphics.print(t.ctext,
            pos.x + math.floor(random_offset.x / 12), pos.y)

            leaf.color(255, 0, 0, 127.5)
            love.graphics.print(t.ctext,
            pos.x - math.floor(random_offset.y / 12), pos.y)

            -- draw main text --
            leaf.color(255, 255, 255)
            love.graphics.print(t.ctext, pos.x, pos.y)

        elseif t.efx == 'wobbly' then

            leaf.color(255, 255, 255, 127.5)
            -- loop thru the chars --
            for c = 1, #t.ctext do
                love.graphics.print(t.ctext:sub(c, c),
                    pos.x + leaf.font:getWidth(t.ctext:sub(1, c - 1)),
                    pos.y + math.floor(math.sin(leaf.ctm * 16 + c * leaf.font_size) * 2)
                )
            end
        elseif t.efx == 'glitch' then
            -- random control of noise direction
            local ctrl
            if random_offset.y % 24 == 0 then ctrl = 1
            else ctrl = 0 end

            -- control of non-user-end variables --
            if not t.__txt then t.__txt = t.ctext end
            if not t.__fxt then t.__fxt = 0
            elseif t.__fxt > 0 then t.__fxt = t.__fxt - 1 end

            -- if the wating time has ended --
            if t.__fxt == 0 then
                -- update drawing-text value --
                t.__txt = t.ctext

                -- if god has picked up this frame, --
                -- change one of the chars by other --
                if random_offset.x % 32 == 0 then
                    -- pick a random char and replace it --
                    local _p = random_offset.y % #t.ctext + 1
                    t.__txt = t.ctext:gsub(
                        t.ctext:sub(_p, math.min(_p + 2, #t.ctext)),
                        string.char(math.random(33, 127)) ..
                        t.ctext:sub(_p + 1, math.min(_p + 2, #t.ctext))
                    )
                    t.__fxt = 10
                end
            end

            -- once in a while slice the string --
            local half = math.random(1, #t.ctext) * ctrl

            leaf.color(0, 0, 255, 127.5)
            love.graphics.print(t.__txt,
                pos.x - math.floor(random_offset.y / leaf.font_size) *
                math.random(-1, 1) * math.floor(half / 2),

                pos.y - math.floor(random_offset.x / leaf.font_size) *
                math.random(-1, 1) * math.floor(half / 2))

            -- set random offset --
            random_offset.x = math.random(1, 64)
            random_offset.y = math.random(1, 64)

            leaf.color(255, 0, 0, 127.5)
            love.graphics.print(t.__txt,
                pos.x - math.floor(random_offset.y / leaf.font_size) *
                math.random(-1, 1) * math.floor(half / 2),

                pos.y - math.floor(random_offset.x / leaf.font_size) *
                math.random(-1, 1) * math.floor(half / 2))

            -- set random offset --
            random_offset.x = math.random(1, 64)
            random_offset.y = math.random(1, 64)

            leaf.color(255, 255, 255, 127.5)
            love.graphics.print(t.__txt:sub(1, half),
                pos.x - math.floor(random_offset.y / leaf.font_size) *
                math.random(-1, 1) * math.floor(half / 2),

                pos.y - math.floor(random_offset.x / leaf.font_size) *
                math.random(-1, 1) * math.floor(half / 2))

            -- set random offset --
            random_offset.x = math.random(1, 64)
            random_offset.y = math.random(1, 64)

            love.graphics.print(t.__txt:sub(half),
                pos.x + leaf.font:getWidth(t.__txt:sub(1, half))
                - math.floor(random_offset.y / leaf.font_size) * math.random(-1, 1) * half,
                pos.y - math.floor(random_offset.x / leaf.font_size) * math.random(-1, 1) * half)

        elseif t.efx == 'shaking' then
            for c = 1, #t.ctext do
                local r = random_offset.x % 8 == 0
                if r then r = 1 else r = 0 end

                leaf.color(255, 255, 255, 127.5)

                love.graphics.print(t.ctext:sub(c, c),
                    pos.x + (c - 1) * leaf.font:getWidth(t.ctext)
                    - math.floor(random_offset.y % (leaf.font_size / 5)) * math.random(r - 1, 1),
                    pos.y - math.floor(random_offset.x % (leaf.font_size / 5)) * math.random(r - 1, 1))

                -- set random offset --
                random_offset.x = math.random(1, 64)
                random_offset.y = math.random(1, 64)
            end
        end
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

    if not idxr then
        local cntt = #leaf.texts
        local unff = 0

        for _, t in ipairs(leaf.texts) do

            if not leaf.txt_end(t.msg) then unff = unff + 1 end
        end

        leaf.texts = {}
        return cntt, unff
    end

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

-- resset color --
local r, g, b, a

-- graphic functions --
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

    local pos = leaf.vector(x, y)
    if leaf.drawmode == "pixper" then
        pos.x = math.floor(x)
        pos.y = math.floor(y)
    end

    love.graphics.rectangle('line', pos.x, pos.y, w or 1, h or w or 1)
end

function leaf.rectb(x, y, w, h)

    local pos = leaf.vector(x, y)
    if leaf.drawmode == "pixper" then
        pos.x = math.floor(x)
        pos.y = math.floor(y)
    end

    love.graphics.rectangle('fill', pos.x, pos.y, w or 1, h or w or 1)
end
