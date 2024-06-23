/* crocotile threedee passthru vertex shader */

attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

varying vec2 texture_coordinate;
varying vec4 vertex_color;
/* varying vec3 vertex_position; */
/* varying vec3 vertex_normal; */

void main()	{
	vec4 position = vec4(in_Position.xyz, 1.0);
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * position;
	texture_coordinate = in_TextureCoord;
	vertex_color = in_Colour;
	/* vertex_normal = in_Normal; */
	/* vertex_position = (gm_Matrices[MATRIX_WORLD] * position).xyz; */
}