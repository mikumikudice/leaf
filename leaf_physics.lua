--# 2D Vector ----------------------------------------------#--

    function leaf.vector(x, y, scale)

        return {

            lot = 'vector',

            str = function(self)

                return '{' .. (self.x)
                .. ', ' .. (self.y) .. '}'
            end,

            sum = function(self, x, y)

                self.x = self.x + (x or 0)
                self.y = self.y + (y or 0)

                return self
            end,

            sub = function(self, x, y)

                self.x = self.x - (x or 0)
                self.y = self.y - (y or 0)

                return self
            end,

            mul = function(self, x, y)

                self.x = self.x * (x or 1)
                self.y = self.y * (y or 1)

                return self
            end,

            div = function(self, x, y)

                self.x = self.x / (x or 1)
                self.y = self.y / (y or 1)

                return self
            end,

            x = (x or 0) * (scale or 1),
            y = (y or 0) * (scale or 1),
        }
    end

    function leaf.vect4V(lt, rt, up, dn)

        return {

            lt = lt or 0,
            rt = rt or 0,
            up = up or 0,
            dn = dn or 0,
        }
    end

--# Collision ----------------------------------------------#--

    leaf.plat = {}

    function leaf.add_plat(type, pos, wdt, hgt, name)

        local plat = {

            type = type,
            lft = pos.x,
            rgt = pos.x + wdt,

            flr = pos.y,
            rff = pos.y + hgt
        }

        if name then leaf.plat[name] = plat
        else table.insert(leaf.plat, #leaf.plat, plat) end
    end

    -- Set new values (vect4V) to collision --
    function leaf.coll(p, c, down)

        local pos = leaf.table_copy(p)
        pos.x = math.floor(p.x); pos.y = math.floor(p.y)

        local dg = c.size - c.size / 4
        local hf = c.size / 2

        -- Check every platform --
        for _, l in pairs(leaf.plat) do

            -- Check if object is between walls of platform --
            if pos.x > l.lft - c.size and pos.x < l.rgt then
                -- Set Floor --
                if pos.y <= l.flr - c.size and pos.y >= l.flr - c.size - dg then

                    if l.type == "solid" then c.dn = l.flr - c.size end
                    if l.type == "jthru" and not down then c.dn = l.flr - c.size end
                end
                -- Set Roof --
                if pos.y >= l.rff and pos.y <= l.rff + dg then

                    if l.type == "solid" then c.up = l.rff end
                    if l.type ~= "jthru" then c.up = 0 end
                end
            end

            -- Check if object is between floor and roof --
            if pos.y > l.flr - c.size and pos.y < l.rff then

                if l.type ~= 'platf' then
                    -- Set wall at left --
                    if  pos.x <= l.lft - c.size
                    and pos.x >= l.lft - c.size - dg then c.rt = l.lft - c.size end
                    -- Set wall at right --
                    if pos.x >= l.rgt and pos.x <= l.rgt + dg then c.lt = l.rgt end
                end
            end

            -- Fix bug --
            if pos.y > l.flr - c.size and pos.y < l.rff and l.type == 'solid' then

                if  pos.x > l.lft - c.size
                and pos.x <= l.rgt - hf then p.x = l.lft - c.size end

                if  pos.x < l.rgt
                and pos.x >= l.lft - c.size + hf then p.x = l.rgt end
            end
        end
    end

    function leaf.del_plat(name)

        if name then leaf.plat[name] = nil
        else leaf.plat = {} end
    end

    function leaf.draw_plat()

        for _, plat in pairs(leaf.plat) do

            leaf.rectb(
                plat.lft, plat.rff,
                plat.rgt - plat.lft,
                plat.flr - plat.rff
            )
        end
    end

--# Cachable -----------------------------------------------#--

    leaf.items = {}

    function leaf.add_itm(name, ipos, sprt, wall)

        local itm = {

            name = name,
            exst = true,
            x    = ipos.x,
            y    = ipos.y,
            t    = 255
        }

        leaf.items[name] = itm
        leaf.add_tile(name, ipos, sprt, wall)
    end

    function leaf.catch(c)

        for _, itm in pairs(leaf.items) do

            if c.x + c.size >= itm.x          and
               c.x + c.size <= itm.x + c.size and
               c.y == itm.y                  then

                itm.exst = false
                leaf.del_tile(itm.name)

                return itm.name
            end
        end
    end

--# Platform -----------------------------------------------#--

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
        obj.anim  = obj.anim
        obj.clip  = obj.clip

        def.size = def.size or 8
        def.mass = def.mass or 8

    --# Physics control ------------------------------------#--

        -- Screen collision --
        obj.dcol = leaf.vect4V(

            -def.size / 2, leaf.s_wdth - def.size / 2,
            -def.size / 2, leaf.s_hght - def.size / 2
        )
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

        obj.gravity = obj.jmp_stg * (obj.jmp_stg / (obj.jmp_stg / (def.mass * 0.4)))
        obj.maxfall = obj.gravity * 0.4
        obj.on_land = true

        return obj
    end

    function platform:step(dt)

        -- Collision --
        self:collide()

    --# Default control ------------------------------------#--

        if type(self.ctrl.lft) == "string" then
            -- Go to left if object can move --
            if  self.pos.x - self.x_speed <= self.col.rt
            and leaf.btn(self.ctrl.lft) then

                self.pos.x = self.pos.x - self.x_speed

                self.side  = -1
                self.state = "moving"
            -- Go to right if object can move --
            elseif self.pos.x + self.x_speed >= self.col.lt
            and    leaf.btn(self.ctrl.rgt) then

                self.pos.x = self.pos.x + self.x_speed

                self.side  = 1
                self.state = "moving"
            -- Not moving --
            else self.state = "idle" end

    --# Control by MSM -------------------------------------#--

        elseif self.ctrl ~= nil then

            -- Go to left if object can move --
            if self.ctrl.lft == true and
            self.pos.x - self.x_speed <= self.col.rt then

                self.pos.x = self.pos.x - self.x_speed
                self.side  = -1
            end

            -- Go to right if object can move --
            if self.ctrl.rgt == true and
            self.pos.x + self.x_speed >= self.col.lt then

                self.pos.x = self.pos.x + self.x_speed
                self.side  = 1
            end
        end

    --# Jump and gravity -----------------------------------#--

        -- Gravity --
        if self.pos.y < self.col.dn
        or self.y_speed ~= 0 then

            self.pos.y = self.pos.y + self.y_speed * dt

            -- Stop accelerating at 0.4 of the gravity speed --
            self.y_speed = self.y_speed - self.gravity * dt
            self.y_speed = math.max(self.y_speed, self.maxfall)
        end

        -- Stop falling at floor and jumping at roof  --
        if self.pos.y >= self.col.dn
        or self.pos.y <  self.col.up then

            self.y_speed = 0
            -- On landing --
            if self.pos.y >= self.col.dn then

                self.jmp_cnt = self.mx_jcnt or true
                self.on_land = true

                self.pos.y = self.col.dn
            end
        end

        -- Resset jumped boolean --
        self.jmpd = false
        -- Jump if object is on floor and have no space to --
        if  leaf.btnp(self.ctrl.ups)
        and self:can_jmp() then

            self.jmpd = true

            self.y_speed = (self.jmp_stg / 2) * leaf.SSCALE / 2
            self.on_land = false

            if type(self.jmp_cnt) == 'boolean' then

                self.jmp_cnt = false

            else self.jmp_cnt = self.jmp_cnt - 1 end
        end

    --# Resset values --------------------------------------#--

        self.on_rw = false
        self.on_lw = false

        -- Avoid wall trhu --
        self:fix_pos()

    --# Animation ------------------------------------------#--

        if self.anim then
            -- Jumping --
            if self.y_speed < 0 then

                self.anim:play(dt, self.clip.jump, 8, true)

            elseif self.y_speed > 0 then

                self.anim:play(dt, self.clip.fall, 8, true)

            -- Walking and idle --
            elseif self.state == 'moving' then

                self.anim:play(dt, self.clip.walk, 8, true)
            else

                self.anim:play(dt, self.clip.idle, 8, true)
            end
        end
    end

    function platform:draw()

        if self.anim then self.anim:draw(self.pos,  self.side)
        else leaf.rectb(self.pos.x, self.pos.y, self.col.size) end
    end

    function platform:collide()
        -- Reset collision paramters --
        self.col   = leaf.table_copy(self.dcol)
        self.on_land = false

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

        self:fix_pos()

        if not scale then scale = 1 end

        re   = leaf.table_copy(self.pos)
        re.x = math.floor(re.x / scale)
        re.y = math.floor(re.y / scale)

        return re
    end

    function platform:set_pos(npos)
        -- Stop falling --
        self.y_speed = 0

        self.pos = npos
        self:collide()
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
        and jmp_cnt and (self.on_land or num_cnt)
    end

    function platform:on_wall()

        if self.pos.x == self.col.lt or self.pos.x == self.col.rt then return true
        elseif self.on_lw or self.on_rw then return true

        else return false end
    end

    function platform:jumped()  return self.jmpd    end
    function platform:landed()  return self.on_land end
    function platform:get_stt() return self.state   end
    function platform:get_yac() return self.y_speed end
    function platform:get_mrr() return self.side    end

--# PM Ghost -----------------------------------------------#--

    -- The packman-like ghost stays --
    -- in an enclosed area until it --
    -- something to haunt.          --

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

            ['lft'] = true,
            ['rgt'] = false,
            ['ups'] = false,
        }

        self.plat = leaf.new_obj('platform', pos, self.thnk)
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

        -- Create variable --
        if not self.thnk.hate then self.thnk.hate = 0 end

        -- Object inside ghost's view range --
        if  cpos.y <= tpos.y and cpos.y > tpos.y - 8 then self.thnk.hate = 120 * dt end

        -- Object out of view range --
        if cpos.y > tpos.y then self.thnk.hate = 0 end

        -- If ghost is furry yet --
        if self.thnk.hate > 0 then

            -- Get most closer position --
            self.habt.lft = math.max(cpos.x, self.habt.lft)
            self.habt.rgt = math.min(cpos.x, self.habt.rgt)

            -- Decrease furry level --
            self.thnk.hate = self.thnk.hate - dt
        end

        -- Move to left --
        if tpos.x > self.habt.rgt then

            self.thnk.rgt = false
            self.thnk.lft = true
        end

        -- Move to rught --
        if tpos.x < self.habt.lft then

            self.thnk.lft = false
            self.thnk.rgt = true
        end

        -- Beat at wall --
        if self.plat:on_wall() then

            self.thnk.lft = not self.thnk.lft
            self.thnk.rgt = not self.thnk.rgt
        end

        -- Do not get crazy --
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

function leaf.new_obj(otype, ...)

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