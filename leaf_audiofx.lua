function leaf.playlist(main, back, ...)

    leaf.disco = {}
    leaf.tapes = {}

    for _, track in pairs({...}) do

        leaf.tapes[#leaf.tapes] = track
    end

    leaf.tapes.main = love.audio.newSource('tracks/' .. main, 'stream')
    leaf.tapes.back = love.audio.newSource('tracks/' .. back, 'stream')
end

local gramophone = {}

function gramophone.theme()

    leaf.tapes.main:setLooping(true)
    leaf.tapes.main:play()

    leaf.tapes.back:setLooping(true)
    leaf.tapes.back:play()
end

function gramophone.set(thm, stt)

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

    -- 1 ... 7 tracks --
    track = math.min(math.max(track, 0), 7)

    leaf.disco[track] = love.audio.newSource(leaf.tapes[tape], 'static')
    leaf.tapes.main:setLooping(loop)

    leaf.disco[track]:setVolume(track / 7)
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

leaf.gramo = {}
setmetatable(gramophone, leaf.gramo)