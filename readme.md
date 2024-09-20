# some utility functions to help load crocotile3d obj files into gamemaker

i love [crocotile3d](https://crocotile3d.com), you love crocotile3d, but we use gamemaker which is not a threedee engine so we need some help! here is a small but growing collection of resources that i use to get gamemaker and crocotile3d to high five obj files back and forth. these functions are utilities tho, they are not meant for runtime model loading and transforming because loading a obj file at runtime is a huge ask since its parsing a whole-assed text file. so if you are building a level editor, or cooking up a big wad or bin of vertex buffers for your game then these are the functions you would use.

### is there an example?
yeah a bit of a tiny one, albeit. im gunna assume since you're working in gamemaker with threedee then you're a veteran of many wars and no hands will be held: download the repo and extract it to wherever. open up crocotile, go to the `scene` tab in the toolbox, then hit the hamburglar dropdown to import a prefab. navigate on to `Crocotile3D\misc` and import the `viewcube` prefab, then right click it to export it as an obj file. include vertex colors, include the material/texture, and then set the scale to 16; smash export and put both the  `viewcube.obj` file and `texture_1.png` in the included files folder of the gm project. then run that project. hooray! this demo shows off kyle the crocodile with some flat sunlight and playstation wobbling.

**again:** these two files are not included with the project, they come from crocotile3d.

### functions? functions!

**crocotile\_threedee\_parse\_obj\_file**(_file_name_, _[callback]_)
> this function parses the crocotile3d obj file into a bunch of collections of data. *file_name* is the name of the obj file, including the path. the default *callback* method will return a raw buffer of data, not a vertex buffer.

**crocotile\_threedee\_default\_obj\_parsing\_callback**(*vertex\_positions*, *vertex\_normals*, *vertex\_colors*, *vertex\_texture\_coords*, *triangle\_faces*)
> this is the default callback for obj parsing, and it takes on the collections of data collected by the obj parsing function. if you want to write a custom ballback, it will need these same collections.

**crocotile\_threedee\_correct\_to\_plus\_z\_up**(_raw\_vbo\_buffer_, _vertex\_format_)
> this function transforms a crocotile3d obj file to be correct in a positive z-up view matrix. crocotile's up vector and handed-ness doesnt match gm so this is required for converting things. _raw\_vbo\_buffer_ takes a raw buffer of vertex data and _vertex\_format_ is the vertex format you use, but assumes that format is the same as the included default. this function will also correct texture uvs.

**crocotile\_threedee\_write\_buffer\_to\_obj\_file**(*raw\_vbo\_buffer*, *obj\_name*)
> convert a buffer of raw vertex data into an obj file that crocotile can use as a model import. *raw\_vbo\_buffer* is the raw data and *obj\_name* is the name of the obj. **don't** include .obj in the name or you will end up with something.obj.obj which would be weird. **_note!_** crocotile3d has a scale of 1:16 pixels; so 16 pixels in gamemaker is a unit of 1 in crocotile 3d. you will need to downscale your obj when you import it.

**crocotile\_threedee\_uncorrect\_from\_plus\_z\_up**(_raw\_vbo\_buffer_, _vertex\_format_)
> run this sucker when you want to turn a positive z up model back to whatever wildness up vector that crocotile3d uses. probably wanna do this _before_ you turn it into a obj file.

**crocotile\_threedee\_calculate\_flat\_normals**(*raw\_vbo\_buffer*, *vertex\_format*, *normals\_attribute\_number*)
> does what it says on the tin: calculates and then writes flat normals for a raw buffer of vertex data. you will need to pass it your vertex format as well as the zero-indexed index of the normals attribute of your vertex format. for example: in the default format the normals are the second attribute so that is index 1. this one requires an included, vector 3 libary.

**crocotile\_threedee\_reverse\_vertex\_order**(*raw\_vbo\_buffer*, *vertex\_format*)
> whenever you do a non uniform scale transform on a vertex buffer, the winding order of the vertices will be the wrong way! uh oh! so if you scale something on like one axis by -1 or whatever then u will need this.

i definitely plan to add more to this as i go, for example: rounding vertices off to be only integer positions and things like that.


### some general notes
- crocotile3d's upvector and handedness cannot change, even if you alter these in the settings the exported obj will respect the default crocotile camera. you will need conversions!
- gamemaker is weird with the v component of uvs, you will generally end up pulling a 1-v to get the correct v coordinate; these functions handle it for u though.
- i don't use materials so you're on your own there homie

### grid maps
if you right click an object in the scene view of crocotile and select `export misc`, you will notice a little somethin' somethin' that says `export grid map.` grid maps are actually a feature of godot with a croc implementaiton. a godot grid map is almost identitcal to a gamemaker tilemap, only in threedee. for example in gamemaker you have a tilemap that is made of tile indices and each tile index maps that specific cell on the map to a specific tile on the tile set. in godot, you can have a grid map which is made out of indices that point to a specific mesh in a set of meshes.

this is a really neat feature that you can use to do very cool things in your own threedee gamemaker games. like in my current project, i use the grid map data from crocotile to procedurally place tiles on a tilemap in gamemaker for collisions. to do that, i export the grid map from crocotile and then parse it in my gamemaker game with this function:

**crocotile\_threedee\_parse\_gridmap\_file\_z_\up**(*file\_name*, *\[one_meter\]*, *\[as_list\]*, *\[z_direction\]*)
> this function returns a constructor of holding the data about the gridmap.  
> - *file\_name* is the path of the gridmap.txt file you wanna parse.  
> - *one\_meter* is how many pixels is equal to one unit in crocotile. by default in crocotile and this libary we assume this is 16 pixels.  
> - *as\_list* is a boolean value which determines whether or not the data is an array of coordinates with a tile index or as an array grid where each cell is the tile index, defaults to true and returns as list.   
> - *z_direction* is whether or not your z up vector is 1 or -1, defaults to 1.

this function parses the grid map data into two possible formats. a list-of-structs format like this:
```
data = [
    { tile_x : 0, tile_y: 6, tile_z: 9, tile_index : 10 }
    { tile_x : 4, tile_y: 2, tile_z: 0, tile_index : 20 }
]
```
or as an array of arrays of arrays, aka a 3d array, like this:
```
data = [
  [
    [ 0, 4 ],
    [ 2, 0 ]
  ],
  [
    [ 0, 0 ],
    [ 6, 9 ]
  ]
];
```
just like working with tilemap_get and tilemap_set in gamemaker, these are cell positions and indices, not pixel positions. but the constructor does have a method to figure out the world coordinates of a cell, which looks like `data.extract_world_position(x, y, z)` and returns the coordinates as a struct in world coordinates. this respects the sign of the world position too, so index 0,0,0 of a grid of map data can still translate back into negative world positions. the struct of positions is a recycled struct.