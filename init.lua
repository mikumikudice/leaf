leaf = {}
leaf.CVER = "1.3.2"

-- Skip components --
leaf.__unload = {}
function leaf.skip(...)

    local comps = {...}

    for _, c in pairs(comps) do

            if c == 'resources' then leaf.skip_res = true
        elseif c == 'drawtiles' then leaf.skip_dtm = true
        elseif c == 'drawtexts' then leaf.skip_dtx = true
        else leaf.__unload[c] = true end
    end
end

if love then
    local ldd, _conf
    function leaf.init(conf)
        _conf = conf
        ldd   = true
    end

    -- screen configuration --
    function leaf._init(conf)
        -- default config --
        if not conf then conf = {} end
        conf = {
            w = conf.w or 512, h = conf.h or 512,
            s = conf.s or 4,
            mv = conf.mv or true,
            rz = conf.rz or true,
            vs = true,
            dm = conf.dm or "default"
        }
        conf.mw = conf.mw or (conf.w / (conf.s * 2))
        conf.mh = conf.mh or (conf.h / (conf.s * 2))

        leaf.SSCALE = conf.s
        leaf.s_wdth = conf.w / leaf.SSCALE
        leaf.s_hght = conf.h / leaf.SSCALE

        love.window.setMode(conf.w, conf.h, {
            resizable = conf.rz,
            vsync     = conf.vs,
            minwidth  = conf.mw,
            minheight = conf.mh,
        })

        -- fix resolution --
        love.graphics.setDefaultFilter('nearest')

        -- resources --
        if not leaf.skip_res then

            local h_sheet = love.filesystem.getInfo('resources/sprites.png')
            local h_tiled = love.filesystem.getInfo('resources/tilemap.png')

            assert(not (not h_sheet and not h_tiled),
            'missing base resource files (sprite sheet and tilemap palette)')

            assert(h_sheet, 'missing base resource file (sprite sheet)')
            assert(h_tiled, 'missing base resource file (tilemap palette)')

            leaf.sheet = love.graphics.newImage('resources/sprites.png')
            leaf.tiled = love.graphics.newImage('resources/tilemap.png')
        end

        -- set random seed --
        math.randomseed(os.time() + conf.w * conf.h)

        -- drawing method --
        leaf.drawmode = conf.dm
        assert(leaf.table_find({
            'default', 'pixper'
        }, leaf.drawmode), 'the given drawmode is invalid')
    end

    function leaf.preload(...)

        local comps = {...}
        for _, c in pairs(comps) do

            require('leaf/leaf_' .. c .. '.lua')
            leaf.__unload[c] = true
        end
    end

    -- input --
    leaf.inputs = {}
    leaf.inputs.prss = {}
    leaf.inputs.rlss = {}

    function love.keypressed(key)
        -- close program --
        if  key == "escape"
        and love.window.hasFocus() then

            local exit
            if leaf.kill then

                exit = leaf.kill()

            else exit = true end

            if exit then

                love.event.quit()
            end
        end

        leaf.inputs.prss[key] = true
    end

    function leaf.btn(key)

        return love.keyboard.isDown(key)
    end

    function leaf.btnp(key)
        -- return if is empty key --
        if key == '' then return end

        local out = leaf.inputs.prss[key]
        return out
    end

    function love.keyreleased(key)

        leaf.inputs.rlss[key] = true
    end

    function leaf.btnr(key)
        -- return if is empty key --
        if key == '' then return end

        local out = leaf.inputs.rlss[key]
        return out
    end

    -- leaf workflow --
    function love.load()

        local lddl = {'core', 'audiofx', 'physics', 'renderer', 'storange'}

        for _, lib in pairs(lddl) do

            if not leaf.__unload[lib] then

                require('leaf/leaf_' .. lib .. '.lua')
            end
        end

        -- call sub initializer --
        if ldd then
            leaf._init(_conf)
        -- if not called, replace sub with main --
        else leaf.init = leaf._init end

        leaf.ready = true

        if leaf.load then leaf.load() end
    end

    function love.update(dt)
        -- current fps --
        leaf.fps = love.timer.getFPS()
        leaf.ctm = love.timer.getTime()
        leaf.mem = collectgarbage('count') / 1024

        -- update Screen sizw --
        leaf.s_wdth = love.graphics.getWidth()  / leaf.SSCALE
        leaf.s_hght = love.graphics.getHeight() / leaf.SSCALE

        -- leaf global step --
        if leaf.step then leaf.step(dt) end
        if leaf.late then leaf.late()   end

        leaf.inputs.prss = {}
        leaf.inputs.rlss = {}
    end

    function love.draw()

        local scale = love.graphics.getWidth() / leaf.s_wdth
        -- update the drawing --
        -- scale according to --
        -- the screen size    --
        love.graphics.scale(scale, scale)
        -- draw internal objects --
            if leaf.draw_text and
           not leaf.skip_dtx then leaf.draw_text() end
        if not leaf.skip_dtm then leaf.draw_tilemap() end

        if leaf.draw then leaf.draw() end
    end
end
