/* draw a 3d model  */
draw_clear_alpha(#99f599, 1);
camera_apply(threedee_camera);
shader_set(crocotile_threedee_flat_sunlight_shader) {
	var transform_matrix = matrix_build(0, 0, 0, 0, 0, z_rotation, 2, 2, 2);
	matrix_set(matrix_world, transform_matrix);

	vertex_submit(kyle_vbo, pr_trianglelist, kyle_texture_pointer);

	matrix_set(matrix_world, identity_matrix);
	shader_reset();
}