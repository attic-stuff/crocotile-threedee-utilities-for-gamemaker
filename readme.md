# some utility functions to help load crocotile3d obj files into gamemaker

i love crocotile3d, you love crocotile 3d, but we use gamemaker which is not a threedee engine so we need some help! here is a small but growing collection of resources that i use to get gamemaker and crocotile3d to high five obj files back and forth. these functions are utilities tho, they are not meant for runtime model loading and transforming, because loading a obj file at runtime is a huge ask since its parsing a whole ass text file. so if you are building a level editor, or cooking up a big bin of vertex buffers for your game then these are the functions you would use.

### is there an example?
yeah a bit of a tiny one, albeit. im gunna assume since you're working in gamemaker with threedee then you're a veteran of many wars and no hands will be held: download the repo and extract it to wherever. open up crocotile, go to the `scene` tab in the toolbox, then hit the hamburglar dropdown to import a prefab. navigate on to `Crocotile3D\misc` and import the `viewcube` prefab, then right click it to export it as an obj file. include vertex colors, include the material/texture, and then set the scale to 16; smash export and put both the  `viewcube.obj` file and `texture_1.png` in the included files folder of the gm project. then run that project. hooray!

this demo shows off kyle the crocodile with some flat sunlight and playstation wobbling.

**again:** these two files are not included with the project, they come from crocotile3d.

### functions? functions!

**crocotile\_threedee\_parse\_obj\_file**(_file_name_, _[callback]_)
> this function parses the crocotile3d obj file into a bunch of collections of data. *file_name* is the name of the obj file, including the path. the default *callback* method will return a raw buffer of data, not a vertex buffer.

**crocotile\_threedee\_default\_obj\_parsing\_callback**(*vertex\_positions*, *vertex\_normals*, *vertex\_colors*, *vertex\_texture\_coords*, *triangle\_faces*)
> this is the default callback for obj parsing, and it takes on the collections of data collected by the obj parsing function. if you want to write a custom ballback, it will need these same collections.

**crocotile\_threedee\_correct\_to\_plus\_z\_up**(_raw\_vbo\_buffer_, _vertex\_format_)
> this function transforms a crocotile3d obj file to be correct in a positive z-up view matrix. crocotile's up vector and handed-ness doesnt match gm so this is required for converting things. _raw\_vbo\_buffer_ takes a raw buffer of vertex data and _vertex\_format_ is the vertex format you use.

**crocotile\_threedee\_write\_buffer\_to\_obj\_file**(*raw\_vbo\_buffer*, *obj\_name*)
> convertex a buffer of raw vertex data into an obj file that crocotile can use as a model import. *raw\_vbo\_buffer* is the raw data and *obj\_name* is the name of the obj. **don't** include .obj in the name or you will end up with something.obj.obj which would be weird. **_note!_** crocotile3d has a scale of 1:16 pixels; so 16 pixels in gamemaker is a unit of 1 in crocotile 3d. you will need to downscale your obj when you import it.

**crocotile\_threedee\_uncorrect\_from\_plus\_z\_up**(_raw\_vbo\_buffer_, _vertex\_format_)
> run this sucker when you want to turn a positive z up model back to whatever wildness up vector that crocotile3d uses. probably wanna do this _before_ you turn it into a obj file.

**crocotile\_threedee\_calculate\_flat\_normals**(*raw\_vbo\_buffer*, *vertex\_format*, *normals\_attribute\_number*)
> does what it says on the tin: calculates and then writes flat normals for a raw buffer of vertex data. you will need to pass it your vertex format as well as the zero-indexed index of the normals attribute of your vertex format. for example: in the default format the normals are the second attribute so that is index 1. this one requires an included, vector 3 libary.

**crocotile\_threedee\_reverse\_vertex\_order**(*raw\_vbo\_buffer*, *vertex\_format*)
> whenever you do a non uniform scale transform on a vertex buffer, the winding order of the vertices will be the wrong way! uh oh! so if you scale something on like one axis by -1 or whatever then u will need this.

i definitely plan to add more to this as i go, for example: rounding vertices off to be only integer positions and things like that.