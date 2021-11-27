--# 2D vector ----------------------------------------------#--

    --- square object
    --- @class sqr
    --- @field x number
    --- @field y number
    --- @field w number
    --- @field h number

    --- @class sqrdat
    --- @field lt number
    --- @field rt number
    --- @field up number
    --- @field dn number
    --- @field size number for internal use only

    --- @class vector

    --- metamethods of vector
    local mt = {
        __metatable = 'vector',

        __tostring = function(self)

            return string.format('(%f %f)', self.x, self.y)
        end,

        __add = function(self, otr)

            local cpy = leaf.vector(self.x, self.y)
            cpy.x = self.x + otr.x
            cpy.y = self.y + otr.y

            return cpy
        end,

        __sub = function(self, otr)

            local cpy = leaf.vector(self.x, self.y)
            cpy.x = self.x - otr.x
            cpy.y = self.y - otr.y

            return cpy
        end,

        __mul = function(self, otr)

            local cpy = leaf.vector(self.x, self.y)

            if type(otr) == table then

                cpy.x = self.x * otr.x
                cpy.y = self.y * otr.y
            else
                cpy.x = self.x * otr
                cpy.y = self.y * otr
            end

            return cpy
        end,

        __div = function(self, otr)

            local cpy = leaf.vector(self.x, self.y)

            if type(otr) == table then

                cpy.x = self.x / otr.x
                cpy.y = self.y / otr.y
            else
                cpy.x = self.x / otr
                cpy.y = self.y / otr
            end

            return cpy
        end,

        __eq = function(self, otr)

            return self.x == otr.x and self.y == otr.y
        end
    }

    local _up, _down, _left, _right
    _up    = {x = 00, y = 01}
    _down  = {x = 00, y = -1}
    _left  = {x = 01, y = 00}
    _right = {x = -1, y = 00}

    setmetatable(_up   , mt)
    setmetatable(_down , mt)
    setmetatable(_left , mt)
    setmetatable(_right, mt)

    --- instantiates a new 2d vector. If scale is
    --- defined both x and y are multiplicated by
    --- it
    --- @param x number the x position (default 0)
    --- @param y number the y position (default x or 0)
    --- @param scale number the sacale of the values
    --- @return vector
    function leaf.vector(x, y, scale)
        --- @type vector
        local vect = {
            x  = (x or 0) * (scale or 1),
            y  = (y or 0) * (scale or 1),

            -- default arguments --
            up = _up, down = _down,
            left = _left, right = _right
        }

        setmetatable(vect, mt)
        return vect
    end

    --- instantiates a new square data (sqrdat)\
    --- basically a delimited area, defined by up/down side limit and left/right side limit
    --- @param lt number left side
    --- @param rt number right side
    --- @param up number up side
    --- @param dn number down side
    --- @return sqrdat
    function leaf.sqrdat(lt, rt, up, dn)
        --- @type sqrdat
        return {
            lt = lt or 0,
            rt = rt or 0,
            up = up or 0,
            dn = dn or 0,
            size = 1
        }
    end

    --- instantiates a new square (sqr) object
    --- @param x number the x position (default 0)
    --- @param y number the y position (default `x` or 0)
    --- @param w number the square width (default 1)
    --- @param h number the square height (default `w` or 1)
    --- @return sqr
    function leaf.newsqr(x, y, w, h)
        --- @type sqr
        return {
            x = x or 0,
            y = y or x or 0,
            w = w or 1,
            h = h or w or 1,
        }
    end

--# collision ----------------------------------------------#--

    leaf.plat = {}

    --- adds a new platform to the collision context
    --- @param type string sets the platform type: solid / jthru (jump thru)
    --- @param data  sqr the position and dimentions of the platform
    function leaf.add_plat(type, data, name)

        --- @class platform
        --- @field type string platform type
        --- @field lft number left wall value
        --- @field rgt number right wall value
        --- @field flr number floor value
        --- @field rff number roof value
        local plat = {
            type = type,
            lft = data.x,
            rgt = data.x + data.w,

            flr = data.y,
            rff = data.y + data.h
        }

        if name then leaf.plat[name] = plat
        else table.insert(leaf.plat, plat) end
    end

    --- sets new values to collider (sqrdat).\
    --- please do not use this function, instead use a platform object
    --- @param p vector position of the char
    --- @param c sqrdat current platform object collider stat
    --- @param down boolean sets the jumpthru flag (platform tiles become unsolid if true)
    function leaf.coll(p, c, down)

        local pos = leaf.vector(math.floor(p.x), math.floor(p.y))
        local dg  = c.size - c.size / 4
        local hf  = c.size / 2
        -- check every platform --
        for _, l in pairs(leaf.plat) do
            -- check if object is between walls of platform --
            if pos.x > l.lft - c.size and pos.x < l.rgt then
                -- set floor --
                if pos.y <= l.flr - c.size and pos.y >= l.flr - c.size - dg then

                    if l.type == "solid" then c.dn = l.flr - c.size end
                    if l.type == "jthru" and not down then c.dn = l.flr - c.size end
                end
                -- set roof --
                if pos.y >= l.rff and pos.y <= l.rff + dg then

                    if l.type ~= "jthru" then c.up = l.rff
                    else c.up = 0 end
                end
            end

            -- check if object is between floor and roof --
            if pos.y > l.flr - c.size and pos.y < l.rff then

                if l.type ~= 'jthru' then
                    -- set wall at left --
                    if  pos.x <= l.lft - c.size
                    and pos.x >= l.lft - c.size - dg then c.rt = l.lft - c.size end
                    -- set wall at right --
                    if pos.x >= l.rgt and pos.x <= l.rgt + dg then c.lt = l.rgt end
                end
            end

            -- fix bug --
            if pos.y > l.flr - c.size and pos.y < l.rff and l.type == 'solid' then

                if  pos.x > l.lft - c.size
                and pos.x <= l.rgt - hf then p.x = l.lft - c.size end

                if  pos.x < l.rgt
                and pos.x >= l.lft - c.size + hf then p.x = l.rgt end
            end
        end
    end

    --- desc: removes a platform from the collision context\
    --- apdx: works only for named platforms (see leaf.add_plat)
    --- @param name string
    function leaf.del_plat(name)

        if name then leaf.plat[name] = nil
        else leaf.plat = {} end
    end

    --- draws shapes at positions of the platforms
    function leaf.draw_plat()

        leaf.color(255, 255, 255)
        for _, plat in pairs(leaf.plat) do
            leaf.rectb(
                plat.lft, plat.rff,
                plat.rgt - plat.lft,
                plat.flr - plat.rff
            )
            leaf.log('plat', plat.lft, plat.rff,
            plat.rgt - plat.lft,
            plat.flr - plat.rff)
        end
        leaf.color()
    end

--# catchable ----------------------------------------------#--

    leaf.items = {}

    --- desc: adds a new cachable item to the environment \
    --- apdx: adds separately tiles to the tilemap and an data table to leaf.items
    ---@param name     string the item name
    ---@param tsqr     table  the corresponding square descriptor (leaf.newsqr)
    ---@param sprt     string the string containing the characters of its tiles
    ---@param wall     boolean sets the collider status
    function leaf.add_itm(name, tsqr, sprt, wall)

        local itm = {
            name = name,
            exst = true,
            sqr  = tsqr,
            sprt = sprt
        }

        leaf.items[name] = itm
        for i = 1, tsqr.w * tsqr.h do
            local x = tsqr.x + (i - 1) % tsqr.w
            local y = (i - x - 1) / tsqr.w
            local p = leaf.vector(x, y)
            leaf.add_tile(name, p, sprt, wall)
        end
    end

    --- executes the capture of items, if it can happen\
    --- this function checks if the `pos` overlapped with any item\
    --- when something is caught the fuction returns the name of the item
    --- @param pos sqr cacher data
    --- @return string itm
    function leaf.catch(pos)

        for _, itm in pairs(leaf.items) do

            if pos.x + pos.w >= itm.x         and
               pos.x + pos.w <= itm.x + pos.w and
               pos.y + pos.h >= itm.y        then

                itm.exst = false
                leaf.del_tile(itm.name)

                return itm.name
            end
        end
    end

--# platform -----------------------------------------------#--

    local platform = {}
    function platform:load(ipos, ctrl, def)

        local obj = {}

        setmetatable(obj, self)
        self.__index = self

        if not def then def = {} end

        -- Current position --
        obj.pos = ipos

        -- Input control --
        obj.ctrl = ctrl
        obj.side = 1

        -- Animations --
        obj.state = 'idle'
        obj.anim  = def.anim
        obj.clip  = def.clip

        def.size = def.size or 8
        def.mass = def.mass or 8

    --# Physics control ------------------------------------#--

        -- Screen collision --
        if not def.dcol then
            obj.dcol = leaf.sqrdat(

                -def.size / 2, leaf.s_wdth - def.size / 2,
                -def.size / 2, leaf.s_hght - def.size / 2
            )
        else obj.dcol = def.dcol end
        obj.dcol.size = def.size

        obj.col = leaf.table_copy(obj.dcol)

        obj.on_lw = false
        obj.on_rw = false

        -- Movement --
        obj.x_speed = def.speed or def.size / 8
        obj.y_speed = 0

        -- Jump --
        obj.mx_jcnt = def.jump_count
        obj.jmp_cnt = def.jump_count    or true
        obj.jmp_stg = def.jump_strength or -def.mass * 25
        obj.coyotim = def.coyote_time or 0

        obj.gravity = obj.jmp_stg * (obj.jmp_stg / (obj.jmp_stg / (def.mass * 0.4)))
        obj.maxfall = obj.gravity * 0.4
        obj.on_land = true

        return obj
    end

    function platform:step(dt)
        -- resset values --
        self.on_rw   = false
        self.on_lw   = false
        self.jmpd    = false

        if self.on_land then self.coyoefx = self.coyotim end
        if self.coyoefx > 0 then self.coyoefx = self.coyoefx - 1 end
        self.on_land = false

        -- avoid wall trhu --
        self:fix_pos()
        self.is_lndd = self.pos.y == self.col.dn

    --# default control ------------------------------------#--

        if type(self.ctrl.lft) == "string" then
            -- Go to left if object can move --
            if  self.pos.x - self.x_speed <= self.col.rt
            and leaf.btn(self.ctrl.lft) then

                self.pos.x = self.pos.x - self.x_speed * 60 * dt

                self.side  = -1
                self.state = "moving"
            -- Go to right if object can move --
            elseif self.pos.x + self.x_speed >= self.col.lt
            and    leaf.btn(self.ctrl.rgt) then

                self.pos.x = self.pos.x + self.x_speed * 60 * dt

                self.side  = 1
                self.state = "moving"
            -- Not moving --
            else self.state = "idle" end

    --# control by MSM -------------------------------------#--

        elseif self.ctrl ~= nil then
            -- go to left if object can move --
            if self.ctrl.lft == true and
            self.pos.x - self.x_speed <= self.col.rt then

                self.pos.x = self.pos.x - self.x_speed * 60 * dt
                self.side  = -1
            end
            -- go to right if object can move --
            if self.ctrl.rgt == true and
            self.pos.x + self.x_speed >= self.col.lt then

                self.pos.x = self.pos.x + self.x_speed * 60 * dt
                self.side  = 1
            end
        end

    --# jump and gravity -----------------------------------#--

        -- gravity --
        if self.pos.y < self.col.dn
        or self.y_speed ~= 0 then

            self.pos.y = math.max(self.pos.y + self.y_speed * dt, self.col.up)
            -- stop accelerating at 0.4 of the gravity speed --
            self.y_speed = self.y_speed - self.gravity * dt
            self.y_speed = math.max(self.y_speed, self.maxfall)
        end

        -- stop falling at floor and jumping at roof  --
        if self.pos.y >= self.col.dn
        or self.pos.y <= self.col.up then
            -- on_land is true only once landed --
            self.on_land = self.pos.y > self.col.dn and not self.on_land
            -- on landing --
            if self.pos.y >= self.col.dn then

                self.y_speed = 0
                self.jmp_cnt = self.mx_jcnt or true

                self.pos.y = self.col.dn
            -- is at uplimit --
            elseif self.y_speed < 0 then self.y_speed = 0 end
        end

        -- jump if object is on floor and have no space to --
        if  leaf.btnp(self.ctrl.ups)
        and self:can_jmp() then

            self.jmpd = true

            self.y_speed = (self.jmp_stg / 2) * leaf.SSCALE / 2

            if type(self.jmp_cnt) == 'boolean' then

                self.jmp_cnt = false

            else self.jmp_cnt = self.jmp_cnt - 1 end
        end

    --# animation ------------------------------------------#--

        if self.anim then
            -- Jumping --
            if self.y_speed < 0 then

                self.anim:play(dt, self.clip.jump, 8, true)

            elseif self.y_speed > 0 then

                self.anim:play(dt, self.clip.fall, 8, true)
            -- walking and idle --
            elseif self.state == 'moving' then

                self.anim:play(dt, self.clip.walk, 8, true)
            else
                self.anim:play(dt, self.clip.idle, 8, true)
            end
        end
        -- avoid wall trhu --
        self:fix_pos()
        -- collision --
        self:collide()
    end

    function platform:draw()

        if self.anim then self.anim:draw(self.pos,  self.side)
        else leaf.rectb(self.pos.x, self.pos.y, self.col.size) end
    end

    function platform:collide()
        -- Reset collision paramters --
        self.col     = leaf.table_copy(self.dcol)

        -- Give down key if is a playable object --
        if type(self.ctrl.dwn) == "string" then

            leaf.coll(self.pos, self.col, leaf.btn(self.ctrl.dwn))

        else leaf.coll(self.pos, self.col, false) end
    end

    function platform:fix_pos()

        local limit = self.col
        -- Keep object in window --
        if self.pos.x < limit.lt then

            self.on_lw = true
            self.pos.x = limit.lt

        elseif self.pos.x > limit.rt then

            self.on_rw = true
            self.pos.x = limit.rt
        end
    end

    function platform:get_pos(scale)

        if not scale then scale = 1 end

        local  lp = leaf.vector(self.pos.x, self.pos.y)
        return lp / scale
    end

    function platform:set_pos(npos)
        -- zero speed to avoid bugs --
        self.y_speed = 0

        self.pos.x = npos.x
        self.pos.y = npos.y
    end

    function platform:can_jmp()

        local jmp_cnt, num_cnt
        -- Set jump count to boolean --
        if type(self.jmp_cnt) == "number" then

            if self.jmp_cnt > 0 then

                jmp_cnt = true

            else jmp_cnt = false end

            num_cnt = true

        else jmp_cnt = self.jmp_cnt end

        return math.floor(self.pos.y) ~= self.col.up
        and jmp_cnt and (self.is_lndd or self.coyoefx > 0 or num_cnt)
    end

    function platform:on_wall()

        if self.pos.x == self.col.lt
        or self.pos.x +  self.dcol.size
        == self.col.rt then return true
        elseif self.on_lw or self.on_rw then return true

        else return false end
    end

    function platform:jumped()  return self.jmpd    end
    function platform:landed()  return self.is_lndd end
    function platform:onland()  return self.on_land end
    function platform:get_stt() return self.state   end
    function platform:get_yac() return self.y_speed end
    function platform:get_mrr() return self.side    end

--# PM Ghost -----------------------------------------------#--

    -- The packman-like ghost stays --
    -- in an enclosed area until it --
    -- get something to haunt.      --

    local ghost = {}

    function ghost:load()

        local other = {}

        setmetatable(other, self)
        self.__index = self

        return other
    end

    function ghost:init(min, max, pos, clip)
        -- Missing arg --
        if not pos then pos = leaf.vector(0, 0) end

        -- Habitation Space --
        self.dhab = {lft = min, rgt = max} -- Default min and max
        self.habt = {lft = min, rgt = max} -- Current min and max

        -- Ghost --
        self.thnk = {

            lft  = true,
            rgt  = false,
            ups  = false,
            hate = 0
        }

        self.plat = leaf.create('platform', pos, self.thnk)
        self.plat.x_speed = self.plat.x_speed * 0.6 -- Set speed at 60% of max

        -- Ghost animator --
        if clip then

            self.anim = leaf.anim(leaf.vector(clip.idle.row, clip.idle[0]))
            -- Ghost animations --
            self.anim.idle  = clip.idle
            self.anim.angry = clip.angry
        end
    end

    function ghost:step(dt, cpos)
        -- Update habitation space --
        self.habt = leaf.table_copy(self.dhab)
        self:think(dt, cpos)

        self.plat:step(dt)
        -- If object has an animator --
        if self.anim then

            if self.thnk.hate > 0 then

                self.anim:play(dt, self.anim.angry, 8, true)
            else

                self.anim:play(dt, self.anim.idle, 8, true)
            end
        end

        -- Ghost cought char --
        local tpos = self.plat:get_pos()
        if cpos.y <= tpos.y and cpos.y > tpos.y - 8 then

            if (cpos.x + 2 > tpos.x and cpos.x < tpos.x + 2)
            or cpos.x == tpos.x then

                return true

            else return false end

        else return false end
    end

    function ghost:think(dt, cpos)

        local tpos = self.plat:get_pos()

        -- object inside ghost's view range --
        if  cpos.y <= tpos.y and cpos.y > tpos.y - 8 then self.thnk.hate = 160 * dt end
        -- object out of view range --
        if cpos.y > tpos.y and self.thnk.hate > 30 * dt then
            self.thnk.hate = 30 * dt
        end

        -- if ghost is angry yet --
        if self.thnk.hate > 0 then
            -- Get most closer position --
            self.habt.lft = math.max(cpos.x, self.habt.lft)
            -- Decrease hate level --
            self.habt.rgt = math.min(cpos.x, self.habt.rgt)
            self.thnk.hate = self.thnk.hate - dt
        end
        -- move to left --
        if  tpos.x >= self.habt.rgt
        and tpos.x ~= self.habt.lft then

            self.thnk.rgt = false
            self.thnk.lft = true
        end
        -- move to right --
        if  tpos.x <= self.habt.lft
        and tpos.x ~= self.habt.rgt then

            self.thnk.lft = false
            self.thnk.rgt = true
        end

        -- stomp at wall --
        if self.plat:on_wall() then

            self.thnk.lft = not self.thnk.lft
            self.thnk.rgt = not self.thnk.rgt
        end

        -- avoid stopping --
        if not (self.thnk.rgt or self.thnk.lft) then

            if math.floor(tpos.x) == self.habt.rgt then
                self.thnk.rgt = false
                self.thnk.lft = true
            end
            if math.floor(tpos.x) == self.habt.lft then
                self.thnk.lft = false
                self.thnk.rgt = true
            end
        end

        -- Lerp the traking --
        if math.floor(tpos.x / 8) == math.floor(cpos.x / 8) and self.thnk.hate > 0 then

            self.thnk.lft = false
            self.thnk.rgt = false
        end

        -- Haunt object --
        if self.thnk.hate > 0 then

            -- Move to left --
            if cpos.x < tpos.x then

                -- Stop in the edge --
                if tpos.x >= self.habt.lft + 1 then

                    self.thnk.lft = true
                    self.thnk.rgt = false
                else

                    self.thnk.lft = false
                    self.thnk.rgt = false
                end
            end

            -- Move to right --
            if cpos.x > tpos.x then

                -- Stop in the edge --
                if tpos.x <= self.habt.rgt - 1 then

                    self.thnk.rgt = true
                    self.thnk.lft = false
                else

                    self.thnk.lft = false
                    self.thnk.rgt = false
                end
            end
        end
    end

    function ghost:draw()

        -- Draw ghost --
        if self.anim then

            self.anim:draw(self.plat:get_pos(), self.plat:get_mrr())
        else

            local pos = self.plat:get_pos()
            leaf.rectb(pos.x, pos.y, 8)
        end
    end

function leaf.create(otype, ...)

    -- Calling out of an scope --
    assert(leaf.ready, 'cannot initialize objects before leaf.load')

    local object

    if otype == 'platform' then

        object = platform:load(...)

    elseif otype == 'pm-ghost' then

        object = ghost:load()
        object:init(...)
    end

    return object
end
