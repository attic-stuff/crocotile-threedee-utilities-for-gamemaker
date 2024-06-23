/* crocotile threedee flat sunlight fragment shader */

varying vec2 texture_coordinate;
varying vec4 vertex_color;
varying vec3 vertex_lighting;

void main() {
	vec4 color = vertex_color * texture2D(gm_BaseTexture, texture_coordinate);
	color.rgb = color.rgb * vertex_lighting;
	if (color.a == 0.0) {
		discard;
	}
	gl_FragColor = color;
}