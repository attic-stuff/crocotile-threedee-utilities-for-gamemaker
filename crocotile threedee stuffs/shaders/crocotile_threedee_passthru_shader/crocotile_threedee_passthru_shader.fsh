/* crocotile threedee passthru fragment shader */

varying vec2 texture_coordinate;
varying vec4 vertex_color;
/* varying vec3 vertex_position; */
/* varying vec3 vertex_normal; */

void main() {
	vec4 color = vertex_color * texture2D(gm_BaseTexture, texture_coordinate);
	gl_FragColor = color;
}