function leaf.playlist(main, back, ...)

    leaf.tapes = {}
    local cntt = 0
    for _, track in ipairs({...}) do

        leaf.tapes[cntt] = love.audio.newSource('tracks/' .. track, 'static')
        cntt = cntt + 1
    end

    if main then

        assert(love.filesystem.getInfo('tracks/' .. main), 'main tape not found')
        leaf.tapes.main = love.audio.newSource('tracks/' .. main, 'stream')
    end

    if back then

        assert(love.filesystem.getInfo('tracks/' .. back), 'main tape not found')
        leaf.tapes.back = love.audio.newSource('tracks/' .. back, 'stream')
    end
end

local gramophone = {}

function gramophone.theme()

    leaf.tapes.main:setLooping(true)
    leaf.tapes.main:play()

    leaf.tapes.back:setLooping(true)
    leaf.tapes.back:play()
end

function gramophone.set(thm, stt)
    assert(leaf.tapes, 'no playlist defined yet')
    if thm == 'main' then

        if stt then leaf.tapes.main:resume()
        else leaf.tapes.main:pause() end
    end

    if thm == 'back' then

        if stt then leaf.tapes.back:resume()
        else leaf.tapes.back:pause() end
    end
end

function gramophone.play(tape, track, loop)

    if loop == nil then loop = false end

    assert(leaf.tapes, 'no playlist defined yet')
    assert(tape and track, 'invalid gramophone\'s parameters')
    -- 0 to 7 tracks --
    track = math.min(math.max(track, 0), 7)

    assert(leaf.tapes[tape], 'invalid tape ('.. tape .. ')')

    leaf.tapes[tape]:setLooping(loop)
    leaf.tapes[tape]:setVolume((8 - track) / 8)
    leaf.tapes[tape]:play()
end

function gramophone.pause(track)

    if not leaf.disco[track] then return end
    leaf.disco[track]:pause()
end

function gramophone.resume(track)

    if not leaf.disco[track] then return end
    leaf.disco[track]:resume()
end

function gramophone.fade_in(track, speed)

    -- Make speed/s as speed/dt
    speed = (speed * love.timer.getDelta()) / love.timer.getFPS()

    if not leaf.disco[track]  then return end
    if leaf.disco[track].fade then

        -- Resume if is not playing --
        if leaf.disco[track].fade == 0 then

            leaf.disco[track]:resume()
        end

        -- While not at max --
        if leaf.disco[track].fade < 1 then

            local volume = math.min(leaf.disco[track].fade + speed, 1)

            leaf.disco[track]:setVolume(volume)
            leaf.disco[track].fade = leaf.disco[track]:getVolume()

        -- Clear fade at the end --
        else leaf.disco[track].fade = nil end

    else leaf.disco[track].fade = leaf.disco[track]:getVolume() end
end

function gramophone.fadeout(track, speed)

    -- Make speed/s as speed/dt
    speed = (speed * love.timer.getDelta()) / love.timer.getFPS()

    if not leaf.disco[track] then return end
    if not leaf.disco[track].fade then

        leaf.disco[track].fade = leaf.disco[track]:getVolume()

    elseif leaf.disco[track].fade > 0 then

        local valume = math.max(leaf.disco[track].fade - speed, 0)

        leaf.disco[track]:setVolume(valume)
        leaf.disco[track].fade = leaf.disco[track]:getVolume()

    else gramophone.stop(track) end
end

leaf.gramo = gramophone
