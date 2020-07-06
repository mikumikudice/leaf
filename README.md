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

leaf is a single lua file that can be loaded by ``require`` or ``dofile`` functions.

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

Do not use love.load | update | draw, would replace the Leaf's functions. Instead, use leaf.load | step | draw.

# API Reference

-`leaf.init(w, h, s, rz, mw, mh, vs)`<br/>
Set the screen size (`w` x `h`), the drawing scale (`s`), if the screen is resizeable (`rz`), the min screen size (`mw` x `mh`) and if vsync is enabled (`vs`). Default values: `s = 1, rz = true, mw | mh = s * 2, vs = true`.
 
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
Return `idx, itm` of the first item in `lst`.

- `leaf.table_last(lst)`<br/>
Return `idx, itm` of the last item in `lst`.

- `leaf.table_find(lst, itm)`<br/>
Return the index of the `itm` if it is in `lst`, otherwise return `nil`.

- `leaf.table_eq(lst, otr)`<br/>
Return `true` if `lst` has the same items in the same indexes of `otr`, otherwise return `false`.

- `leaf.table_eq(lst)`<br/>
Return an copy of `lst`.

## String
- `leaf.string_split(str, pat)`<br/>
Return a table of substrings splited by `pat` from `str`, return `str` if doesn't find `pat`.

## Bool
- `leaf.tobool(str, pat)`<br/>
Convert value to bool. `true` if is `"true"`, `not 0` or `not nil`.

## Debug
Simple print all function.

- `leaf.debug(tag, [...])`<br/>
print `tag` followed by all subsequent values (`...`). e.g.

    ```lua
    leaf.debug('debug', true, 4, 6 - 9)
    
    >>> [debug][true, 4, -3]
    ```

## Graphics
- `leaf.popup(usr, msg)`<br/>
Create a pop-up window to `usr` with `msg` as content. (Avaliable only on Windows and Linux).

- `leaf.set_col([r, g, b, [a]])`<br/>
Same of `love.graphics.setColor()`, but uses 0 to 255 scale, and all `a` is optional. If empty, resset the color to default.

- `leaf.rect(x, y, [w], [h])`<br/>
Draw an `w` x `h` rectangle (line draw method) at {`x`, `y`}. If `w` is `nil`, `w` and `h` will be `1`, if only `h` is `nil`, `h` will be `w`.

- `leaf.rectb(x, y, [w], [h])`<br/>
Draw an `w` x `h` rectangle (fill draw method) at {`x`, `y`}. If `w` is `nil`, `w` and `h` will be `1`, if only `h` is `nil`, `h` will be `w`.

## Input
- ESC key<br/>
Quit the application.

- `leaf.btn(key)`<br/>
Return `true` if `key` is pressed, otherwise return `false`.

- `leaf.btnp(key)`<br/>
Return `true` if `key` is pressed at that frame, otherwise return `false`.

- `leaf.btnr(key)`<br/>
Return `true` if `key` is released at that frame, otherwise return `false`.

## Text Class
- `leaf.txt_conf(font, size, speed)`<br/>
Set the default font as `font`, at size `size` and the class will tye 1 letter by `speed` (seconds).

- `leaf.new_txt(tmsg, ypos, [effect], [trigger, tgrTime])`<br/>
Add a new text object, that will be drawed at height `ypos` and alligned at center (acording to the size). Better with monospace fonts. If `trigger` is definided (a `table` with the letter positions) the text will wait `1/tgrTime` seconds before continue. If this text object already exists, nothing happens.

* `effect = 'noises'` : will draw some red and blue shadows behind the text.

- `leaf.type_txt(dt, [sound])`<br/>
Update all text objects, playing the tape `sound` if given (See Gramophone).

- `leaf.txt_exist(idxr)`<br/>
Return `true` if an text object has `idxr` as content.

- `leaf.txt_end(idxr)`<br/>
Return `true` if the text object that has `idxr` as content has ended.

- `leaf.del_txt(idxr)`<br/>
Remove the text object that has `idxr` as content.

- `leaf.pop_text()`<br/>
Remove all text objects that has ended.

* Text Objects are automatically drawn.

## 2D Vectors
- `leaf.vector([x], [y], [s])`<br/>
Return a new 2D vector at {`x`, `y`} with optional scale (`s`). If empty, return a {`0`, `0`} vector.

- `leaf.vect4D([lt], [rt], [up], [dn])`<br/>
Return a 4dir vector with values left (`lt`), right (`rt`), up (`up`) and down (`dn`). If empty, return all values as `0`.

## Global colliders
- `leaf.add_plat(type, pos, wdt, hgt, name)`<br/>
Add a new platform of the type `type` (`'solid'` or `'jthru'`) of size `wdt` x `hgt` at `pos` (`vector`), identified by `name`.

- `leaf.coll(pos, coll, [down])`<br/>
Update `coll` (`vect4D`) with all solid walls near `pos`. Ignore the floor (`coll.dn`) if the platform is `jthru` and `down` is `true`.

- `leaf.del_plat(name)`<br/>
delete the `name` platform.

- `leaf.draw_plat()`<br/>
Sraw all platforms.

## Collectable items
- `leaf.add_itm(name, ipos, sprt, [wall])`<br/>
Add a collectable item at `ipos`, rendered with `sprt` (`vector`). Will be a solid tile if `wall` is `true`.

- `leaf.catch(coll)`<br/>
Destroy overlapped items by `call` (`vector`) and return item name if was caught.

## Tile map
- `leaf.tilemap(main, back, info, [obj])`<br/>
Set the tile map of the game.
    
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
Add an tile with the indexer `name` at `spos` (`vector`) rendered with `sprt` (`vector`). If `wall` is true, the tile will be solid.

- `leaf.del_tile(name)`<br/>
Delete the `name` tile.

## Platform Object
`leaf.new_obj(otype, ...)`<br/>
Return a platform object of the `otype`.

* Functions common to all platform types.

- `platform:step(dt, [cpos])`<br/>
Update `platform` object (moviment, collision, animaiton). If `platform` is an `pm-ghost`, the object will haunt the `cpos` position (`vector`). 

- `platform:draw()`<br/>
Draw `platform` object. If object has no animator, a rectangle will be drawn instead.

- `platform:get_pos([scale])`<br/>
Return a `vector` with the current position of `platform`. The `s` parameter will be used as scale, if given.

- `platform:set_pos(npos)`<br/>
Set the `platform` position to `npos` (`vector`).

- `platform:get_stt()`<br/>
Return the current animation state of `platform` (`idle` or `moving`).

- `platform:get_yac()`<br/>
Return current `Y` axis acceleration.

- `platform:get_jmp()`<br/>
Return current Y axis acceleration.

- `platform:jumped()`<br/>
Return `true` if `platform` has jumped at that frame.

- `platform:on_wall()`<br/>
Return `true` if the `platform` is leaning against a horizontal wall.

- `platform:landed()`<br/>
Return `true` if the `platform` is landed.

- `platform:get_mrr()`<br/>
Return the mirror state of `platform`. `-1` if sprite is flipped, `1` if is not.

### platform
`(ipos, ctrl, [def])`<br/>
Return a playable object, instantiated at `ipos`, using `ctrl` as key definition. `def` is used do give an animator object and physics parameters. e.g.
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
    idle  = leaf.asrc('idle', 2, 0, 04),
    angry = leaf.asrc('idle', 2, 5, 10),
}

ghost = leaf.new_obj('pm-ghost', 0, 32, leaf.vector(), clip)
```
