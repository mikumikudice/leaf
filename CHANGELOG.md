## 1.5.0
\+ now able to spawn different types of enemies with the tilemapper<br/>
\+ now able to set multiple layers of tilemap<br/>
\+ coyote time option for platform objects<br/>
\* fixed bug with tilemapper (autotiling for solid blocks not working properly)<br/>
\* fixed drawing functions (rect and rectb)<br/>

## 1.4.1
\+ added luadoc documentation (work in progress: 1/5 done)<br/>
## 1.4.0
\+ added more text effects<br/>
\* fixed justified text rendering<br/>
## 1.3.8: cleanup
\+ fixed some shadowed warings like local redefinition<br/>

## 1.3.7 patch
\* fixed crash at `leaf_renderer.lua`<br/>

## 1.3.7
\+ added drawmodes and changed leaf.init arguing method<br\>

## 1.3.6
\- platform object movement bug (not fixed with dt)<br/>

### 1.3.5
\+ option to manually call text\_renderer<br/>
\* changed platforms physics definitions<br/>
\* fixed nulity error in text rendering<br/>
\* fixed typing sound<br/>
\* fixed obj spawning in tilemaper<br/>
\* fixed new\_txt assertions<br/>
\* fixed set\_pos issues with gravity in platform object<br/>
\* fixed leaf\_storange issues (not serializing strings correctly)<br/>
\* fixed tilemaper not clearing old platforms<br/>

### 1.3.4
\+ new function to platform objects (onland)<br/>
\+ memusage value (leaf.mem)<br/>
\+ bg\_color; sets the background color<br/>
\+ custom physics for catchable items in autotiling<br/>
\* a lot of fixes in audiofx (had not tested until now)<br/>
\* fixed autotiling for items (several bugs such as collision and positioning)<br/>
\* only closes window if it's in focus<br/>
\* fixed platform object physics (collision issues like stomping at walls)

### 1.3.3
\+ custom default\_collision (def.decol) for platform objects<br/>
\* fixed tilemap position indexer (not returning spawn point)<br/>
\----
\* fixed tilemap layer 2 rendering (not adding tiles if info is defined)<br/>

### 1.3.2
\* fixed autotiling physics (tile to platform not working)<br/>
\* changed catchable item insertion method<br/>

### 1.3.1
\+ default vector directions<br/>
\* better input handler for btnp and btnr<br/>
\* changed tilemap method functionality<br/>
\* renamed leaf.debug to leaf.log<br/>
\* better formating in leaf.log<br/>
\* renamed leaf.new\_obj to leaf.create<br/>

### 1.3.0
\+ metamethods and metadata for vector type<br/>
\+ now leaf.color can ommit alpha<br/>
\* updated leaf.debug to support vector's changes<br/>
\* renamed leaf.set\_col to leaf.color

### 1.2.0
\+ preload pethod<br/>
\+ custom platform object size and weight<br/>

### 1.1.1
\+ object init error (out of scopes) catcher<br/>
\* fixed default collision values (platform object)<br/>
\* other minor code changes<br/>
\- double jump bug

### 1.1.0
\+ autotiling for items<br/>
\+ able to skip auto-drawing of the tile map (`leaf.skip("drawtiles")`)<br/>
\* string functions integration with string type<br/>
\- debug bug (attempt to index "a.lot" (a nil value))<br/>
\- some Animator bugs (op sprites in def type)<br/>

### 1.0.4
\+ new functionalities to vector object.

### 1.0.3
\+ pm-ghost new behaviour<br/>
\- gramophone syntax error

### 1.0.2
\+ added leaf.ansrc (Animation Source) function and type

### 1.0.1
\+ added subfunction (\_init) to avoid initialization bug (wrong scren size).
