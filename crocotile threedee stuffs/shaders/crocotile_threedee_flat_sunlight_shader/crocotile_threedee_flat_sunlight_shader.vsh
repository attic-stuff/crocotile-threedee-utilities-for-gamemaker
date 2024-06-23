/* crocotile threedee flat sunlight vertex shader */

attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

varying vec2 texture_coordinate;
varying vec4 vertex_color;
varying vec3 vertex_lighting;


void main()	{
	vec4 position = vec4(in_Position.xyz, 1.0);
	
	/* playstation ass jitter */
	vec4 screen_position = gm_Matrices[MATRIX_WORLD_VIEW] * position;
	screen_position.xy = floor(screen_position.xy / screen_position.z * 256.0) * screen_position.z / 256.0;
	gl_Position = gm_Matrices[MATRIX_PROJECTION] * screen_position;
	
	texture_coordinate = in_TextureCoord;
	vertex_color = in_Colour;
	vec3 vertex_normal = normalize((gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0.0)).xyz);
	vec3 sun_direction = vec3(-1.0, -1.0, -1.0);
	/* sorry this is undreadable */
	vertex_lighting = clamp(vec3(0.3, 0.3, 0.3) + vec3(1.0, 1.0, 1.0) * max(dot(vertex_normal, -normalize(sun_direction) ), 0.0), vec3(0.0, 0.0, 0.0), vec3(1.0, 1.0, 1.0));
}