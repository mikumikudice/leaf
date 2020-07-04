# <img src="icon.png">

**leaf** (Love's Extensions And Facilities) is collection of libraries and classes for LÖVE. The structure of code and name of functions is entirely based on Pyxel by Kitao.

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
