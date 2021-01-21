### 1.3.3
\+ custom default\_collision (def.decol) for platform objects<br/>
\* fixed tilemap position indexer (not returning spawn point)<br/>

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
