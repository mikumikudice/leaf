# <img src="icon.png">

**leaf** (Love's Extensions And Facilities) is collection of libraries and classes for LÖVE. The structure of code and name of functions is entirely based on [ [Pyxel](https://github.com/kitao/pyxel)] by Kitao.

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
Set the screen size (`w` x `h`), the drawing scale (`s`), if the screen is resizeable (`rz`), the min screen size (`mw` x `mh`) and if vsync is enabled (`vs`). Default values: s = 1, rz = true, mw/mh = s * 2, vs = true.
 
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

## Input
- `leaf.btn(key)`<br/>
Return `true` if `key` is pressed, otherwise return `false`.

- `leaf.btnp(key)`<br/>
Return `true` if `key` is pressed at that frame, otherwise return `false`.

- `leaf.btnr(key)`<br/>
Return `true` if `key` is released at that frame, otherwise return `false`.

## 2D Vectors
- `leaf.vector(x, y, s)`<br/>
Return a new 2D vector at {`x`, `y`} with optional scale (`s`).

- `leaf.vect4D(lt, rt, up, dn)`<br/>
Return a 4dir vector with values left (`lt`), right (`rt`), up (`up`) and down (`dn`).

## Global colliders
- `leaf.add_plat(type, pos, wdt, hgt, name)`<br/>
Add a new platform of the type `type` (`'solid'` or `'jthru'`) of size `wdt` x `hgt` at `pos` (`vector`), identified by `name`.

- `leaf.coll(pos, coll, down)`<br/>
Update `coll` (`vect4D`) with all solid walls near `pos`. Ignore the floor (`coll.dn`) if the platform is `jthru` and `down` is true.

- `leaf.del_plat(name)`<br/>
delete the `name` platform.

- `leaf.draw_plat()`<br/>
Sraw all platforms.

## Collectable items
- `leaf.add_itm(name, ipos, sprt, wall)`<br/>
Add a collectable item at `ipos`, rendered with `sprt` (`vector`). Will be a solid tile if `wall` is true.

- `leaf.catch(coll)`<br/>
Destroy overlapped items by `call` and return item name if was caught.

## Tile map
- `leaf.tilemap(main, back, info, obj)`<br/>
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
