# <img src="icon.png">

**leaf** (Love's Extensions And Facilities) is collection of libraries and classes for LÖVE. The structure of code and name of functions is entirely based on [[Pyxel](https://github.com/kitao/pyxel)] by Kitao.

leaf is open source and free to use.

## Features

- Shorter functions' names
- On Key Pressed Once
- Screen configurator

- Object Platform and Multiple-State Machine Enemy classes
- Tiledmap (physic and graphic) creator
- 2D Colision system
- Sprite Animator class

- Save-Load build-in system
- NES-Like resources system

- Simple debug function
- New Table and strings functions

## How to Use

leaf is a single lua file that can be loaded by the `require` or `dofile` functions.

```lua
require 'leaf'

leaf.skip('resources')
leaf.init(480, 480, 3)

local x, y = 0, 0

function leaf.step(dt)

    if leaf.btn('a') then x = x - 1
    elseif leaf.btn('d') then x = x + 1 end

    if leaf.btn('w') then y = y - 1
    elseif leaf.btn('s') then y = y + 1 end
end

function leaf.draw()
    
    leaf.rectb(x, y, 4)
end
```

Do not use love.load | update | draw, it would override the Leaf's functions. Instead, use leaf.load | step | draw.

# API Reference

-`leaf.init(w, h, s, rz, mw, mh, vs)`<br/>
Sets the screen size (`w` x `h`), the drawing scale (`s`), if the screen is resizeable (`rz`), the min screen size (`mw` x `mh`) and if vsync is enabled (`vs`). Default values: `s = 1, rz = true, mw | mh = s * 2, vs = true`.
 
 - `leaf.load` <br/>
 Works like `love.load`.
 
 - `leaf.step`<br/>
 Works like `love.update`.
 
 - `leaf.late`<br/>
 Called after `leaf.step`.
 
 - `leaf.draw`<br/>
 Works like `love.draw`.
 
- `leaf.fps`<br/>
The current fps.

- `leaf.s_wdth`<br/>
The current game screen width (real size / scale).

- `leaf.s_hght`<br/>
The current game screen Height (real size / scale).

## Table
- `leaf.table_first(lst)`<br/>
Returns `idx, itm` of the first item in `lst`.

- `leaf.table_last(lst)`<br/>
Returns `idx, itm` of the last item in `lst`.

- `leaf.table_find(lst, itm)`<br/>
Returns the index of the `itm` if it is in `lst`, otherwise return `nil`.

- `leaf.table_eq(lst, otr)`<br/>
Returns `true` if `lst` has the same items in the same indexes of `otr`, otherwise return `false`.

- `leaf.table_eq(lst)`<br/>
Returns an copy of `lst`.

## String
- `leaf.string_split(str, pat)`<br/>
Returns a table of substrings splited by `pat` from `str`, return `str` if doesn't find `pat`.

## Bool
- `leaf.tobool(str, pat)`<br/>
Converts value to bool. `true` if is `"true"`, `not 0` or `not nil`.

## Debug
Simple print all function.

- `leaf.debug(tag, [...])`<br/>
prints `tag` followed by all subsequent values (`...`). e.g.

    ```lua
    leaf.debug('debug', true, 4, 6 - 9)
    
    >>> [debug][true, 4, -3]
    ```

## Graphics
- `leaf.popup(usr, msg)`<br/>
Creates a pop-up window to `usr` with `msg` as content. (Avaliable only on Windows and Linux).

- `leaf.set_col([r, g, b, [a]])`<br/>
Same of `love.graphics.setColor()`, but uses 0 to 255 scale, and all `a` is optional. If empty, resset the color to default.

- `leaf.rect(x, y, [w], [h])`<br/>
Draws an `w` x `h` rectangle (line draw method) at {`x`, `y`}. If `w` is `nil`, `w` and `h` will be `1`, if only `h` is `nil`, `h` will be `w`.

- `leaf.rectb(x, y, [w], [h])`<br/>
Draws an `w` x `h` rectangle (fill draw method) at {`x`, `y`}. If `w` is `nil`, `w` and `h` will be `1`, if only `h` is `nil`, `h` will be `w`.

## Input
- ESC key<br/>
Quits the application.

- `leaf.btn(key)`<br/>
Returns `true` if `key` is pressed, otherwise return `false`.

- `leaf.btnp(key)`<br/>
Returns `true` if `key` is pressed at that frame, otherwise return `false`.

- `leaf.btnr(key)`<br/>
Returns `true` if `key` is released at that frame, otherwise return `false`.

## Text Class
- `leaf.txt_conf(font, size, speed)`<br/>
Sets the default font as `font`, at size `size` and the class will tye 1 letter by `speed` (seconds).

- `leaf.new_txt(tmsg, ypos, [effect], [trigger, tgrTime])`<br/>
Adds a new text object, that will be drawed at height `ypos` and alligned at center (acording to the size). Better with monospace fonts. If `trigger` is definided (a `table` with the letter positions) the text will wait `1/tgrTime` seconds before continue. If this text object already exists, nothing happens.

* `effect = 'noises'` : will draw some red and blue shadows behind the text.

- `leaf.type_txt(dt, [sound])`<br/>
Updates all text objects, playing the tape `sound` if given (See Gramophone).

- `leaf.txt_exist(idxr)`<br/>
Returns `true` if an text object has `idxr` as content.

- `leaf.txt_end(idxr)`<br/>
Returns `true` if the text object that has `idxr` as content has ended.

- `leaf.del_txt(idxr)`<br/>
Removes the text object that has `idxr` as content.

- `leaf.pop_text()`<br/>
Removes all text objects that has ended.

* Text Objects are automatically drawn.

## 2D Vectors
- `leaf.vector([x], [y], [s])`<br/>
Returns a new 2D vector at {`x`, `y`} with optional scale (`s`). If empty, return a {`0`, `0`} vector.

- `leaf.vect4D([lt], [rt], [up], [dn])`<br/>
Returns a 4dir vector with values left (`lt`), right (`rt`), up (`up`) and down (`dn`). If empty, return all values as `0`.

## Global colliders
- `leaf.add_plat(type, pos, wdt, hgt, name)`<br/>
Adds a new platform of the type `type` (`'solid'` or `'jthru'`) of size `wdt` x `hgt` at `pos` (`vector`), identified by `name`.

- `leaf.coll(pos, coll, [down])`<br/>
Updates `coll` (`vect4D`) with all solid walls near `pos`. Ignore the floor (`coll.dn`) if the platform is `jthru` and `down` is `true`.

- `leaf.del_plat(name)`<br/>
deletes the `name` platform.

- `leaf.draw_plat()`<br/>
Draws all platforms.

## Collectable items
- `leaf.add_itm(name, ipos, sprt, [wall])`<br/>
Adds a collectable item at `ipos`, rendered with `sprt` (`vector`). Will be a solid tile if `wall` is `true`.

- `leaf.catch(coll)`<br/>
Destroys overlapped items by `call` (`vector`) and return item name if was caught.

## Tile map
- `leaf.tilemap(main, back, info, [obj])`<br/>
Sets the tile map of the game.
    
  `main` table with the tiles of the main layer.<br/>
  `back` table with tiles at the background (not solid).<br/>
  `info` table with the definition of the tiles.<br/>
  `obj` optional arg. Will spawn this emeny at every `hab` found.<br/>
  e.g.
  
```lua
info = {

    dict = { -- dictionary of sprites corresponding to each character

        ['O'] = leaf.vect(00, 00),
        ['='] = leaf.vect(00, 01),
        ['x'] = leaf.vect(00, 04),

        ['nil'] = leaf.vect(64, 64) -- Default sprite to unknow characters
    },

    thru = {'='}, -- dictionary of Jump Thru platforms
    skip = {'x'}, -- dictionary of tiles to be ignored
}

main = {

    [0] = 'O O O O O O',
    [1] = 'O x x x x O',
    [2] = 'O x x x x O',
    [3] = 'O x = = x O',
    [4] = 'O x x x x x',
    [5] = 'O O O O O O',
}

back = {

    [0] = 'x x x x x x',
    [1] = 'x _ @ _ _ x',
    [2] = 'x _ _ _ _ x',
    [3] = 'x _ x x _ x',
    [4] = 'x # _ _ # _',
    [5] = 'x x x x x x',
}

obj = {

    name = 'enemy',
    clip = {

        idle  = leaf.asrc('idle' , 1, 0, 4),
        angry = leaf.asrc('antry', 1, 5, 9),
    }
}

leaf.tilemap(main, back, info, obj)
```

This code will create a tile map 6 x 6, where `O` is an solid tile with an sprite at `0` x `0` in the `tilemap.png` file (see Resources), `=` is an Jump Thru platform with an sprite at `0` x `1` (the `x` will be ignored in `main`). An enemy, definided by `obj` will be spawned at {`4`, `1`} and will habitate the area `0` to `4`. The function will also return a character spawn position, at {`1.4`, `2.4`} (the `@` char plus 0.4).

- `leaf.add_tile(name, spos, sprt, wall)`<br/>
Adds an tile with the indexer `name` at `spos` (`vector`) rendered with `sprt` (`vector`). If `wall` is true, the tile will be solid.

- `leaf.del_tile(name)`<br/>
Deletes the `name` tile.

## Platform Object
`leaf.new_obj(otype, ...)`<br/>
Returns a platform object of the `otype`.

* Functions common to all platform types.

- `platform:step(dt, [cpos])`<br/>
Updates `platform` object (moviment, collision, animaiton). If `platform` is an `pm-ghost`, the object will haunt the `cpos` position (`vector`). 

- `platform:draw()`<br/>
Draws `platform` object. If object has no animator, a rectangle will be drawn instead.

- `platform:get_pos([scale])`<br/>
Returns a `vector` with the current position of `platform`. The `s` parameter will be used as scale, if given.

- `platform:set_pos(npos)`<br/>
Sets the `platform` position to `npos` (`vector`).

- `platform:get_stt()`<br/>
Returns the current animation state of `platform` (`idle` or `moving`).

- `platform:get_yac()`<br/>
Returns current `Y` axis acceleration.

- `platform:get_jmp()`<br/>
Returns current Y axis acceleration.

- `platform:jumped()`<br/>
Returns `true` if `platform` has jumped at that frame.

- `platform:on_wall()`<br/>
Returns `true` if the `platform` is leaning against a horizontal wall.

- `platform:landed()`<br/>
Returns `true` if the `platform` is landed.

- `platform:get_mrr()`<br/>
Returns the mirror state of `platform`. `-1` if sprite is flipped, `1` if is not.

### platform
`(ipos, ctrl, [def])`<br/>
Returns a playable object, instantiated at `ipos`, using `ctrl` as key definition. `def` is used do give an animator object and physics parameters. e.g.
```lua
ctrl = {

    lft = 'left' , -- move to left
    rgt = 'right', -- move to right
    dwn = 'down' , -- climb down
    
    int = 'up', -- interact
    ups = 'x' , -- jump
    atk = 'c' , -- atack
}

def = {
    
    speed = 1.5,         -- moviment speed
    anim  = leaf.anim(), -- animator object
    clip  = {

        jump = leaf.asrc('def-jump', 0, 6),       -- jumping animation clip
        fall = leaf.asrc('def-fall', 0, 7),       -- falling animation clip

        idle = leaf.asrc('def-idle', 0, 0, 4),    -- idle animation clip
        walk = leaf.asrc('stp-walk', 0, 4, 0, 5), -- walking animation clip
        
        jump_count    = 2    -- Count of jumps
        jump_strength = -200 -- Jump strength
    }
}

char = leaf.new_obj('platform', leaf.vector(), ctrl, def)
```

## pm-ghost
`(min, max, pos, [clip])`<br/>
Platform Packman-like enemy. Runs the area from `min` to `max`, but is instantiated at `pos`. If defined, the `clip` will be used as an animator object, containing the idle and angry animation clips. e.g.
```lua
clip = {
    
    -- Same name to change only sprites --
    idle  = leaf.asrc('idle', 2, 0, 4),
    angry = leaf.asrc('idle', 2, 5, 9),
}

ghost = leaf.new_obj('pm-ghost', 0, 32, leaf.vector(), clip)
```

## Resources
Leaf uses two png files ("tilemap.png" to the tile map class and "sprites.png" to animator objects) in `resources/` as graphic sources and all files in `tracks/` as audio souces. The graphic files will be automaticly loaded, except if you use `leaf.skip('resources')`.

## Animator Object
Animation class, responsible for controlling and animating sprites.

- `leaf.anim([frame])`<br/>
Returns an animator object. If `frame` (`vector`) is specified, the animator will be initialized in this frame.

- `leaf.asrc(name,  ...)`<br/>
Returns an animation source, taged with `name`, that can hold a prefix that expecify the animation type.
   * `('def-name', rw, fx, lx, [opt])`<br/>
   Default type, the same without a prefix. Returns a sprite sheet animation source, in the `rw` row, from the` fx` to `lx` columns. If `opt` (`{spr, cnt}`) is specified, optional frames (`spr`) will be appended at the end of the animation `cnt` times.
    
   * `('stp-name', rw, fx, mx, lx)`<br/>
   Stepped type. Returns a sprite sheet animation source, interleaved animation of fx and lx separated by mx (`{fx, mx, lx, mx}`).

- `anim:play(dt, anim, speed, loop)`<br/>
Causes object `anim` to play animation` anim` at speed `speed` (frames per second). If `loop` is specified, the animation will be looping.

- `anim:loop()`<br/>
Causes object `anim` to loop the current animation.

- `anim:draw(pos, side)`<br/>
Draws the current animation of `anim` at `pos` (`vector`). If `side` is smaller than 0, the sprite will be flipped, if it's greater, will not.

## Gramophone
- `leaf.playlist(main, back, ...)`<br/>
Sets the playlist of audio souce. `main` (`tracks/<main>`) is the main music layer, `back` is the background environment. `...` is all other play-once sounds of the game (sfx), like soundsteps, hits, etc. * Max 8 tracks (0 to 7).

- `leaf.gramo.theme()`<br/>
Starts playing the main and background musics.

- `leaf.gramo.set(thm, stt)`<br/>
Sets playing status of `thm` (`'main'` or `'back'`) to `stt` (boolean).

- `leaf.gramo.play(tape, track, loop)`<br/>
Plays `tape` (indexed in `leaf.playlist`) at sound layer `track`. If `loop` is true, `tape` will play in looping. The volume will be set to `track / 7`.

- `leaf.gramo.pause(track)`<br/>
Pauses `track` if it exists.

- `leaf.gramo.resume(track)`<br/>
Resumes `track` if it exists.

- `leaf.gramo.fade_in(track, speed)`<br/>
Increases the volume of `track` from 0 to 1 in `speed` (percent per second).

- `leaf.gramo.fadeout(track, speed)`<br/>
Decreases the volume of `track` from 1 to 0 in `speed` (percent per second).

## Serializable data
- `leaf.save_data(file, data, [method, msg])`<br/>
Saves a file named `file` containing the data of `data` (string, number or table) in the standard LÖVE directory, using an optional method.
   * `method = nil`<br/>
   Standart method. Save all data inside a .lua file.

   * `method = 'safe'`<br/>
   Magic method. Saves the file as a `file` and store the data in a slightly difficult way to change it. It usually causes errors of nullity if done (not sure why). It also adds `msg` as a message at the top of the file.
   
- `leaf.load_data(file, method)`<br/>
Returns the content of `file`. If an method was used to save the file, it must be specified with `method`.
