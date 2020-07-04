leaf = {}

-- Facilities --
function leaf.debug(tag, ...)
    
    local arg = {...}
    
    -- Make all arguments strings --
    for i, a in pairs(arg) do
        
        arg[i] = tostring(a)
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

function leaf.string_split(str, pat)
    
    -- Table to store substrings --
    local subs = {}

    -- For every word --
    while true do

        -- Get index of substring (div) --
        local findx, lindx = str:find(pat)

        -- Store last substring --
        if not findx then

            subs[#subs + 1] = str
            break
        end

        -- Store the substring before (div) --
        subs[#subs + 1], str = str:sub(1, findx - 1), str:sub(lindx + 1)
    end

    return subs
end

function tobool(value)
    
    if type(value) == 'string' then
    if value:lower() == 'true' then return true
    end
    
    elseif type(value) == 'number' then return value ~= 0
    else return value ~= nil end
end

--# 2D Vector ----------------------------------------------#--

    function leaf.vector(x, y, scale)
        
        return {

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

        plat = {
    
            type = type,
            lt_w = pos.x - 8,
            rt_w = pos.x + wdt,
    
            fr_w = pos.y - 8,
            rf_w = pos.y + hgt
        }
    
        if name then leaf.plat[name] = plat
        else table.insert(leaf.plat, #leaf.plat, plat) end
    end

    -- Set new values (vect4V) to collision --
    function leaf.coll(pos, coll, down)
        
        local vect = leaf.table_copy(pos)
        
        vect.x = math.floor(vect.x)
        vect.y = math.floor(vect.y)
    
        -- Check every platform --
        for _, l in pairs(leaf.plat) do
    
            -- Check if object is between walls of platform --
            if vect.x > l.lt_w and vect.x < l.rt_w then
    
                -- Set Floor --
                if vect.y <= l.fr_w and vect.y >= l.fr_w - 6 then
    
                    if l.type == "solid" then coll.dn = l.fr_w end
                    if l.type == "jthru" and not down then coll.dn = l.fr_w end
                end
    
                -- Set Roof --
                if vect.y >= l.rf_w and vect.y <= l.rf_w + 6 then
    
                    if l.type == "solid" then coll.up = l.rf_w end
                    if l.type == "jthru" then coll.up = 0 end
                end
            end
    
            -- Check if object is between floor and roof --
            if vect.y > l.fr_w and vect.y < l.rf_w then
    
                if l.type == 'solid' then
                
                    -- Set wall at left --
                    if vect.x <= l.lt_w and vect.x >= l.lt_w - 6 then coll.rt = l.lt_w end
                
                    -- Set wall at right --
                    if vect.x >= l.rt_w and vect.x <= l.rt_w + 6 then coll.lt = l.rt_w end
                end
            end
    
            -- Fix bug --
            if vect.y > l.fr_w and vect.y < l.rf_w and l.type == 'solid' then
            if vect.x > l.lt_w and vect.x <= l.rt_w - 4 then pos.x = l.lt_w end
            if vect.x < l.rt_w and vect.x >= l.lt_w + 4 then pos.x = l.rt_w end
            end
        end
    end

    function leaf.del_plat(name)

        if name then leaf.plat[name] = nil
        else leaf.plat = {} end
    end
    
    function leaf.draw_plat()
    
        for _, plat in pairs(leaf.plat) do
        
            leaf.rectb(plat.lt_w + 8, plat.fr_w + 8, 8)
        end
    end

--# Cachable -----------------------------------------------#--

    leaf.items = {}

    function leaf.add_itm(name, ipos, sprt, wll)

        local itm = {
    
            ['name'] = name,
            ['exst'] = true,
    
            ['x'] = ipos.x,
            ['y'] = ipos.y,
            
            ['t'] = 255
        }
    
        leaf.items[name] = itm
        leaf.add_tile(name, ipos, sprt, wll)
    end
    
    function leaf.catch(coll)
    
        for _, itm in pairs(leaf.items) do
            
            if coll.x + 8 >= itm.x  and
            coll.x + 8 <= itm.x + 8 and
            coll.y == itm.y then
                
                itm.exst = false
                leaf.del_tile(itm.name)
    
                return itm.name
            end
        end
    end
    
    local function blink(it)
    
        if not it.exst and it.t > 0 then 
    
            local r, g, b, a = love.graphics.getColor()
    
            love.graphics.setColor(99/255, 199/255, 77/255, it.t/255)
            love.graphics.rectangle('fill', it.x, it.y, 8, 8)
            it.t = it.t - 10
    
            love.graphics.setColor(r, g, b, a)
        end
    end

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

    function leaf.tilemap(main, back, info, obj)

        leaf.mainground = {}
        leaf.background = {}

        -- Clear platforms --
        leaf.del_plat()

        -- Tiles' definitions --
        local _dict, _thru, _skip = info.dict, info.thru, info.skip

        -- Create Enemies --
        local spawn
        local enemy = {}
        local temp_x  = 0
        local temp_y  = 0
        local invoke = false

        -- For every line in the map --
        for ty, line in pairs(main) do

            -- Split Line --
            local splitd = leaf.string_split(line, ' ')

            -- For every tile in splited line --
            for tx, tile in pairs(splitd) do

                -- Get the tile sprite --
                local this = _dict[tile]
                
                -- Unknow tile --
                if not this then this = _dict['nil'] end

                -- Set position and draw quad --
                local tpos = leaf.vector(tx - 1, ty, 8)
                local sprt = love.graphics.newQuad(

                    this.x * 8,
                    this.y * 8,
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
            local splitd = leaf.string_split(line, ' ')

            -- For every tile in splited line --
            for tx, tile in pairs(splitd) do

                -- Get sprite in the _dictionary --
                local this = _dict[tile]

                -- Unknow block --
                if not this then this = _dict['nil'] end

                -- Set position --
                local tpos = leaf.vector((tx - 1) * 8, ty * 8)

                -- Spawn point --
                if tile == '@' then
                    
                    spawn = leaf.table_copy(tpos)

                    spawn.x = spawn.x + 4
                    spawn.y = spawn.y + 4

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

                else

                    -- Create quad --
                    local sprt = love.graphics.newQuad(

                        this.x * 8,
                        this.y * 8,
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

    function leaf.add_tile(name, spos, spr, wll)

        local spr = love.graphics.newQuad(
            
            spr.x * 8,
            spr.y * 8,
            8,
            8,
            leaf.tiled:getDimensions()
        )

        leaf.mainground[name] = block:load(0)
        leaf.mainground[name]:init(spos, spr)

        if wll == true then
            
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

--# Platform -----------------------------------------------#--

    local platform = {}
    function platform:load()

        local other = {}

        setmetatable(other, self)
        self.__index = self

        return other
    end

    function platform:init(ipos, ctrl, def)
    
        if not def then def = {} end

        -- Current position --
        self.pos = ipos
    
        -- Input control --
        self.ctrl = ctrl
        self.side = 1
    
        -- Animations --
        self.state = 'idle'
        self.anim  = def.anim
        self.clip  = def.clip
    
    --# Physics control ------------------------------------#--
    
        -- Screen collision --
        self.d_col = leaf.vect4V(
        
            0, leaf.s_wdth - 4,
            0, leaf.s_hght - 4
        )
        
        self.w_col = leaf.table_copy(self.d_col)
    
        self.on_lw = false
        self.on_rw = false
    
        -- Movement --
        self.x_speed = def.speed or 1
        self.y_speed = 0
    
        -- Jump --
        self.mx_jcnt = def.jump_count
        self.jmp_cnt = def.jump_count    or true
        self.jmp_stg = def.jump_strength or -200

        self.gravity = self.jmp_stg * (self.jmp_stg / (self.jmp_stg / 3.2))
        self.maxfall = self.gravity * 0.4
        self.on_land = true
    end

    function platform:step(dt)

        -- Collision --
        self:collide()

    --# Default control ------------------------------------#--
        
        if type(self.ctrl.lft) == "string" then
    
            -- Go to left if object can move --
            if leaf.btn(self.ctrl.lft) and
            self.pos.x - self.x_speed <= self.w_col.rt then
                
                self.pos.x = self.pos.x - self.x_speed
                
                self.side  = -1
                self.state = "moving"
    
            -- Go to right if object can move --
            elseif leaf.btn(self.ctrl.rgt) and
            self.pos.x + self.x_speed >= self.w_col.lt then
    
                self.pos.x = self.pos.x + self.x_speed
                
                self.side  = 1
                self.state = "moving"
            
            -- Not moving --
            else self.state = "idle" end
    
    --# Control by MSM -------------------------------------#--
    
        elseif self.ctrl ~= nil then
    
            -- Go to left if object can move --
            if self.ctrl.lft == true and
            self.pos.x - self.x_speed <= self.w_col.rt then
    
                self.pos.x = self.pos.x - self.x_speed
                self.side  = -1
            end
    
            -- Go to right if object can move --
            if self.ctrl.rgt == true and
            self.pos.x + self.x_speed >= self.w_col.lt then
    
                self.pos.x = self.pos.x + self.x_speed
                self.side  = 1
            end
        end
    
    --# Jump and gravity -----------------------------------#--

        -- Gravity --
        if self.y_speed ~= 0 or self.pos.y < self.w_col.dn then
    
            self.pos.y = self.pos.y + self.y_speed * dt

            -- Stop accelerating at 0.4 of the gravity speed --
            self.y_speed = self.y_speed - self.gravity * dt
            self.y_speed = math.max(self.y_speed, self.maxfall)
        end
    
        -- Stop falling at floor and jumping at roof  --
        if self.pos.y >= self.w_col.dn or self.pos.y < self.w_col.up then
    
            self.y_speed = 0
    
            -- On landing --
            if self.pos.y >= self.w_col.dn then
                
                self.jmp_cnt = self.mx_jcnt or true
                self.on_land = true
    
                self.pos.y = self.w_col.dn
            end
        end

        -- Resset jumped boolean --
        self.jmpd = false

        -- Jump if object is on floor and have no space to --
        if  leaf.btnp(self.ctrl.ups)
        and self:can_jmp() then

            self.jmpd = true

            self.y_speed = (self.jmp_stg / 2) * leaf.SSCALE / 2
            self.jmp_cnt = false
            self.on_land = false
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

        if self.anim then self.anim:draw(self.pos, self.side)
        else leaf.rectb(self.pos.x, self.pos.y, 8) end
    end

    function platform:collide()
        
        -- Reset collision paramters --
        self.w_col   = leaf.table_copy(self.d_col)
        self.on_land = false

        -- Give down key if is a playable object --
        if type(self.ctrl.dwn) == "string" then
            
            leaf.coll(self.pos, self.w_col, leaf.btn(self.ctrl.dwn))
    
        else leaf.coll(self.pos, self.w_col, false) end
    end

    function platform:fix_pos()

        local limit = self.w_col

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
    
    function platform:get_stt()
    
        return self.state
    end
    
    function platform:get_yac()
    
        return self.y_speed
    end
    
    function platform:can_jmp()
        
        local jmp_cnt

        -- Set jump count to boolean --
        if type(self.jmp_cnt) == "number" then

            if self.jmp_cnt > 0 then
                
                jmp_cnt = true
            end

        else jmp_cnt = self.jmp_cnt end

        return math.floor(self.pos.y) ~= self.w_col.up
        and jmp_cnt and self.on_land
    end

    function platform:jumped()
        
        return self.jmpd
    end
    
    function platform:on_wall()
    
        if self.pos.x == self.w_col.lt or self.pos.x == self.w_col.rt then return true
        elseif self.on_lw or self.on_rw then return true
            
        else return false end
    end

    function platform:landed()
    
        return self.on_land
    end
    
    function platform:get_mrr()
    
        return self.side
    end

--# PM Ghost -----------------------------------------------#--

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
        
            if self.thnk.furry > 0 then
            
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
    
    function ghost:think(dt,cpos)

        local tpos = self.plat:get_pos()

        -- Create variable --
        if not self.thnk.furry then self.thnk.furry = 0 end
    
        -- Object inside ghost's view range --
        if  cpos.y <= tpos.y and cpos.y > tpos.y - 8 then self.thnk.furry = 120 * dt end
        
        -- Object out of view range --
        if cpos.y > tpos.y then self.thnk.furry = 0 end
    
        -- If ghost is furry yet --
        if self.thnk.furry > 0 then
    
            -- Get most closer position --
            self.habt.lft = math.max(cpos.x, self.habt.lft)
            self.habt.rgt = math.min(cpos.x, self.habt.rgt)
    
            -- Decrease furry level --
            self.thnk.furry = self.thnk.furry - dt
        end
    
        -- Move to left --
        if tpos.x >= self.habt.rgt then
    
            self.thnk.rgt = false
            self.thnk.lft = true
        end
    
        -- Move to rught --
        if tpos.x <= self.habt.lft then
    
            self.thnk.lft = false
            self.thnk.rgt = true
        end
    
        -- Do not get crazy --
        if math.floor(tpos.x / 8) == math.floor(cpos.x / 8) and self.thnk.furry > 0 then
            
            self.thnk.lft = false
            self.thnk.rgt = false
        end
    
        -- Haunt object --
        if self.thnk.furry > 0 then
    
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
        if self.afps ~= speed then self.reload = true end
        if self.reload then
    
            self.afps = speed
            self.timr = 1 / self.afps
    
            self.cfrm = anim[0]
            self.nfrm = -1
    
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
            if self.nfrm > #anim - 1 and loop then self.nfrm = 0 end
            if self.nfrm > #anim - 1 and not loop then return true end
    
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

        local xoff = math.min(math.min(8 * side, 8), 0)
        love.graphics.draw(leaf.sheet, self.quad, pos.x - xoff, pos.y, 0, side, 1)
    end

    function leaf.anim(ifrm)
        
        local out = anim:load()
        out:init(ifrm)

        return out
    end

--# Gramophone ---------------------------------------------#--

    function leaf.playlist(main, back, ...)
        
        leaf.disco = {}
        leaf.tapes = {}

        for _, track in pairs({...}) do
            
            leaf.tapes[#leaf.tapes] = track
        end

        leaf.tapes.main = main
        leaf.tapes.back = back
    end

    local gramophone = {}

    function gramophone.play(tape, track, loop)
        
        leaf.disco[track] = love.audio.newSource(leaf.tapes[tape], 'static')
        leaf.disco[track]:play()
    end

    function gramophone.pause(track)

        if not leaf.disco[track] then return end
        leaf.disco[track]:pause()
    end

    function gramophone.resume(track)

        if not leaf.disco[track] then return end
        leaf.disco[track]:resume()
    end
    
    function gramophone.fade_in(track, speed, max)
    
        -- Do not explode --
        if not max then max = 10 end

        -- Make speed/s as speed/dt
        speed = (speed * love.timer.getDelta()) / love.timer.getFPS()

        if not leaf.disco[track]  then return end
        if leaf.disco[track].fade then
            
            -- Resume if is not playing --
            if leaf.disco[track].fade == 0 then
                
                leaf.disco[track]:resume()
            end

            -- While not at max --
            if leaf.disco[track].fade < max then
            
                local volume = math.min(leaf.disco[track].fade + speed, max)

                leaf.disco[track]:setVolume(valume)
                leaf.disco[track].fade = leaf.disco[track]:getVolume()
            
            -- Clear fade at the end --
            else leaf.disco[track].fade = nil end

        else return end
    end

    function gramophone.fadeout(track, speed)
    
        if not leaf.disco[track] then return end
        if not leaf.disco[track].fade then
        
            leaf.disco[track].fade = leaf.disco[track]:getVolume()
        
        elseif leaf.disco[track].fade > 0 then
        
            local valume = math.max(leaf.disco[track].fade - speed, 0)

            leaf.disco[track]:setVolume(valume)
            leaf.disco[track].fade = leaf.disco[track]:getVolume()
        
        else gramophone.stop(track) end
    end

    leaf.gramo = {}
    setmetatable(gramophone, leaf.gramo)

--#---------------------------------------------------------#--

function leaf.new_obj(otype, ...)
    
    local object
    
    if otype == 'platform' then
        
        object = platform:load()
        object:init(...)
    
    elseif otype == 'pm-ghost' then

        object = ghost:load()
        object:init(...)
    end

    return object
end

local _w, _h, _s, _rz, _mw, _mh, _vs
function leaf.init(w, h, s, rz, mw, mh, vs)
    
    _w, _h, _s, _rz, _mw, _mh, _vs = w, h, s, rz, mw, mh, vs
end

-- Screen configuration --
function leaf._init(w, h, s, mv, rz, mw, mh, vs)
    
    if rz == nil then rz = true  end
    if vs == nil then vs = true  end

    local min_w = w / (s * 2)
    local min_h = h / (s * 2)

    leaf.SSCALE = s
    leaf.s_wdth = w / s
    leaf.s_hght = h / s

    love.window.setMode(w, h, {
        
        resizable = rz,
        vsync     = vs,
        minwidth  = mw or min_w,
        minheight = mh or min_h,
    })

    -- Fix resolution --
    love.graphics.setDefaultFilter('nearest')

    -- Mouse is visible --
    if mv ~= nil then love.mouse.setVisible(mv) end

    -- Resources --
    if not leaf.skip_res then

        local h_sheet = love.filesystem.getInfo('resources/sprites.png')
        local h_tiled = love.filesystem.getInfo('resources/tilemap.png')

        if not h_sheet and not h_tiled then

            assert(false, 'Missing base resource files (sprite sheet and tilemap palette)')

        elseif not h_sheet then

            assert(false, 'Missing base resource file (sprite sheet)')

        elseif not h_tiled then

            assert(false, 'Missing base resource file (tilemap palette)')

        else
            
            leaf.sheet = love.graphics.newImage('resources/sprites.png')
            leaf.tiled = love.graphics.newImage('resources/tilemap.png')
        end
    end

    -- Set random seed --
    math.randomseed(os.time() + w * h)
end

-- Skip components --
function leaf.skip(...)
    
    local comps = {...}

    for _, c in pairs(comps) do
        
        if c == 'resources' then leaf.skip_res = true end
    end 
end

-- Text type --
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
        t.pos.x = leaf.s_wdth / 2 - (#t.ctext * 12) / 2

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

function leaf.txt_end(idxr)
    
    for i, t in pairs(leaf.texts) do
        
        if t.msg == idxr then
            
            return t.ended
        end
    end
end

function leaf.txt_exist(idxr)
    
    for i, t in pairs(leaf.texts) do
        
        if t.msg == idxr then
            
            return true
        end
    end

    return false
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

        love.graphics.setColor(nr/255, ng/255, nb/255, na/255)
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

function love.keypressed(key)

    -- Close program --
    if key == "escape" then
        
        local exit
        if leaf.kill then
            
            exit = leaf.kill() 
        
        else exit = true end

        if exit then 
            
            love.event.quit()
        end
    end

    leaf.inputs.prss = key
end

function leaf.btnp(key)
    
    -- Return if is empty key --
    if key == '' then return end
    return key == leaf.inputs.prss
end

function love.keyreleased(key)

    leaf.inputs.rlss = key
end

function leaf.btnr(key)
    
    -- Return if is empty key --
    if key == '' then return end
    return key == leaf.inputs.rlss
end

-- Storange --
function leaf.save_data(file, data, method, msg)

    local meta, success, message

    -- Safe method --
    if method == 'safe' then
        
        -- Create file or read it --
        local line = msg .. '\n' or 'gamedata\n'

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

        local meta

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
    if not success then
    
        assert(message)
    end
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
        line = leaf.string_split(line, '\n')

        -- Remove message --
        line[1] = nil

        -- Read every line --
        for idx, itm in pairs(line) do

            -- Get value name and value --
            splt = leaf.string_split(itm, ':')

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

-- leaf workflow --
function love.load()
    
    -- Init sub internal initializer --
    leaf._init(_w, _h, _s, _rz, _mw, _mh, _vs)
    
    if leaf.load then leaf.load() end
end

function love.update(dt)

    -- Current fps --
    leaf.fps = love.timer.getFPS()

    -- Update Screen sizw --
    leaf.s_wdth = love.graphics.getWidth()  / leaf.SSCALE
    leaf.s_hght = love.graphics.getHeight() / leaf.SSCALE

    -- Leaf global step --
    if leaf.step then leaf.step(dt) end
    if leaf.late then leaf.late(dt) end

    -- Clear inputs --
    if leaf.inputs.prss and leaf.inputs.prss ~= '' and
    love.keyboard.isDown(leaf.inputs.prss) then
        
        leaf.inputs.prss = ''
    end

    if leaf.inputs.rlss and leaf.inputs.prss ~= '' and
    not love.keyboard.isDown(leaf.inputs.rlss) then
        
        leaf.inputs.rlss = ''
    end
end

function love.draw()

    local scale = love.graphics.getWidth() / leaf.s_wdth

    -- Update the drawing --
    -- scale according to --
    -- the screen size    --
    love.graphics.scale(scale, scale)

    -- Draw internal objects --
    draw_text()
    leaf.draw_tilemap()

    if leaf.draw then leaf.draw() end
end